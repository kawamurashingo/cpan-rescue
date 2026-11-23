#!/bin/bash
# Linux-only integration test. All firewall changes occur in new namespaces.
set -euo pipefail

test_dir=$(cd -- "$(dirname -- "$0")" && pwd)
prefix="crssh-$$"
host_ns="$prefix-h"
sender_ns="$prefix-s"
tester_ns="$prefix-t"
server_pids=()
namespaces=()

cleanup() {
    local pid ns
    for pid in "${server_pids[@]}"; do
        kill "$pid" 2>/dev/null || :
    done
    for pid in "${server_pids[@]}"; do
        wait "$pid" 2>/dev/null || :
    done
    for ns in "${namespaces[@]}"; do
        ip netns delete "$ns" || :
    done
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [ "$EUID" -ne 0 ]; then
    echo 'Run as root on a disposable Linux CI runner.' >&2
    exit 1
fi
for tool in ip nft perl; do
    command -v "$tool" >/dev/null || { echo "Missing $tool" >&2; exit 1; }
done

for ns in "$host_ns" "$sender_ns" "$tester_ns"; do
    ip netns add "$ns"
    namespaces+=("$ns")
    ip -n "$ns" link set lo up
done

connect_guest() {
    local guest=$1 bridge=$2 subnet=$3
    # Create both ends inside namespaces; never attach to a real host bridge.
    ip -n "$host_ns" link add "$bridge" type veth peer name guest0
    ip -n "$host_ns" link set guest0 netns "$guest"
    ip -n "$guest" link set guest0 name eth0
    ip -n "$host_ns" addr add "10.$subnet.0.1/24" dev "$bridge"
    ip -n "$guest" addr add "10.$subnet.0.2/24" dev eth0
    ip -n "$host_ns" link set "$bridge" up
    ip -n "$guest" link set eth0 up
    ip -n "$guest" route add default via "10.$subnet.0.1"
}
connect_guest "$sender_ns" vmbr1 151
connect_guest "$tester_ns" vmbr2 152
ip netns exec "$host_ns" sysctl -q -w net.ipv4.ip_forward=1

start_server() {
    local ns=$1
    shift
    ip netns exec "$ns" perl -MIO::Socket::INET -MIO::Select -e '
        my @sockets = map {
            IO::Socket::INET->new(LocalAddr => "0.0.0.0", LocalPort => $_,
                Proto => "tcp", Listen => 10, ReuseAddr => 1) or die "$!\n"
        } @ARGV;
        my $select = IO::Select->new(@sockets);
        while (my @ready = $select->can_read) {
            for my $socket (@ready) {
                my $client = $socket->accept or die "$!\n";
                print {$client} "test listener\n";
                close $client;
            }
        }
    ' "$@" &
    server_pids+=("$!")
}
start_server "$host_ns" 22 8006
start_server "$sender_ns" 22 8022
start_server "$tester_ns" 22 8022

connect() {
    local ns=$1 ip=$2 port=$3
    ip netns exec "$ns" perl -MIO::Socket::INET -e '
        my $s = IO::Socket::INET->new(PeerAddr => $ARGV[0], PeerPort => $ARGV[1],
            Proto => "tcp", Timeout => 1);
        exit 1 unless $s;
        alarm 3;
        my $line = <$s>;
        exit(defined($line) && $line eq "test listener\n" ? 0 : 1);
    ' "$ip" "$port"
}

# Establish that every negative test has a real listener behind it.
for ns in "$host_ns" "$sender_ns" "$tester_ns"; do
    ready=0
    for attempt in {1..30}; do
        if connect "$ns" 127.0.0.1 22; then ready=1; break; fi
        sleep 0.1
    done
    [ "$ready" -eq 1 ] || { echo "Listener failed in $ns" >&2; exit 1; }
done
connect "$host_ns" 127.0.0.1 8006
connect "$sender_ns" 127.0.0.1 8022
connect "$tester_ns" 127.0.0.1 8022

# Reproduce the two independent base-chain drops from the original setup.
ip netns exec "$host_ns" nft -f - <<'NFT'
table inet cpan151_filter {
    chain input {
        type filter hook input priority -50; policy accept;
        iifname "vmbr1" drop
    }
    chain forward {
        type filter hook forward priority -50; policy accept;
        iifname "vmbr1" ip daddr 10.0.0.0/8 drop
        iifname "vmbr1" drop
        oifname "vmbr1" ct state established,related accept
        oifname "vmbr1" drop
    }
}
table inet cpan152_filter {
    chain input {
        type filter hook input priority -50; policy accept;
        iifname "vmbr2" drop
    }
    chain forward {
        type filter hook forward priority -50; policy accept;
        iifname "vmbr2" ip daddr 10.0.0.0/8 drop
        iifname "vmbr2" drop
        oifname "vmbr2" ct state established,related accept
        oifname "vmbr2" drop
    }
}
NFT

expect_blocked() {
    local label=$1
    shift
    if connect "$@"; then
        echo "FAIL (unexpectedly connected): $label" >&2
        exit 1
    fi
    echo "PASS (blocked): $label"
}
expect_allowed() {
    local label=$1
    shift
    connect "$@" || { echo "FAIL (did not connect): $label" >&2; exit 1; }
    echo "PASS (connected): $label"
}

expect_blocked 'original host -> sender SSH' "$host_ns" 10.151.0.2 22
expect_blocked 'original host -> tester SSH' "$host_ns" 10.152.0.2 22
ip netns exec "$host_ns" nft --check --file "$test_dir/../nftables/host-ssh-replies.nft"
ip netns exec "$host_ns" nft --file "$test_dir/../nftables/host-ssh-replies.nft"

expect_allowed 'host -> sender SSH' "$host_ns" 10.151.0.2 22
expect_allowed 'host -> tester SSH' "$host_ns" 10.152.0.2 22
expect_blocked 'host -> sender other TCP port' "$host_ns" 10.151.0.2 8022
expect_blocked 'host -> tester other TCP port' "$host_ns" 10.152.0.2 8022
expect_blocked 'sender -> host SSH' "$sender_ns" 10.151.0.1 22
expect_blocked 'tester -> host SSH' "$tester_ns" 10.152.0.1 22
expect_blocked 'sender -> host management' "$sender_ns" 10.151.0.1 8006
expect_blocked 'tester -> host management' "$tester_ns" 10.152.0.1 8006
expect_blocked 'sender -> tester SSH' "$sender_ns" 10.152.0.2 22
expect_blocked 'tester -> sender SSH' "$tester_ns" 10.151.0.2 22

# Exercise the persistence installer against the existing live tables, then
# recreate those tables from its installed files entirely inside this netns.
test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"; cleanup' EXIT
mkdir "$test_tmp/baseline" "$test_tmp/config"
for id in 151 152; do
    ip netns exec "$host_ns" nft --numeric-priority list table inet "cpan${id}_filter" |
        sed '/cpan-rescue-host-ssh-/d' > "$test_tmp/baseline/cpan$id.nft"
    cp "$test_tmp/baseline/cpan$id.nft" "$test_tmp/config/cpan$id.nft"
done
ip netns exec "$host_ns" sh "$test_dir/../scripts/persist-host-ssh.sh" \
    --baseline-dir "$test_tmp/baseline" --config-dir "$test_tmp/config" --apply
for id in 151 152; do
    ip netns exec "$host_ns" nft delete table inet "cpan${id}_filter"
    ip netns exec "$host_ns" nft --file "$test_tmp/config/cpan$id.nft"
done
expect_allowed 'persistent candidate: host -> sender SSH' "$host_ns" 10.151.0.2 22
expect_allowed 'persistent candidate: host -> tester SSH' "$host_ns" 10.152.0.2 22
expect_blocked 'persistent candidate: sender -> host SSH' "$sender_ns" 10.151.0.1 22
expect_blocked 'persistent candidate: tester -> sender SSH' "$tester_ns" 10.151.0.2 22
echo 'Network isolation integration tests passed.'
