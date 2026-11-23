#!/bin/sh
# Proxmox/Linux: install only the reviewed persistence delta from a known backup.
# Default: prepare a plan. --apply updates files; live nftables is never reloaded.
set -eu
umask 077

fail() { printf 'persist-host-ssh: %s\n' "$*" >&2; exit 1; }
baseline_dir=
config_dir=/root
apply=0
while [ "$#" -gt 0 ]; do
    case "$1" in
        --baseline-dir)
            [ "$#" -ge 2 ] || fail '--baseline-dir needs a directory'
            baseline_dir=$2; shift 2 ;;
        --config-dir)
            [ "$#" -ge 2 ] || fail '--config-dir needs a directory'
            config_dir=$2; shift 2 ;;
        --apply) apply=1; shift ;;
        *) fail 'usage: persist-host-ssh.sh --baseline-dir DIR [--config-dir DIR] [--apply]' ;;
    esac
done
[ -n "$baseline_dir" ] || fail '--baseline-dir is required'
case "$baseline_dir" in /*) ;; *) fail 'baseline directory must be absolute' ;; esac
case "$config_dir" in /*) ;; *) fail 'config directory must be absolute' ;; esac
baseline_dir=$(cd "$baseline_dir" && pwd -P)
config_dir=$(cd "$config_dir" && pwd -P)
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
[ -f "$script_dir/prepare-host-ssh.pl" ] || fail 'prepare-host-ssh.pl must be beside this script'
for tool in perl nft timeout cmp cp diff mv mktemp flock sha256sum; do
    command -v "$tool" >/dev/null 2>&1 || fail "missing command: $tool"
done

# The lock is released by the kernel on exit, including after an interrupted run.
lock_file=$config_dir/cpan-host-ssh-persist.lock
[ ! -L "$lock_file" ] || fail 'lock file must not be a symlink'
exec 9>"$lock_file"
flock -n 9 || fail 'another persistence operation is running'
work_dir=$(mktemp -d "$config_dir/cpan-host-ssh-persist.XXXXXX")
printf 'Backups and candidates: %s\n' "$work_dir"

# Validate both complete files before replacing either. A current file may only
# equal the known pre-change baseline or the exact candidate derived from it.
for id in 151 152; do
    baseline=$baseline_dir/cpan$id.nft
    current=$config_dir/cpan$id.nft
    [ -f "$baseline" ] && [ ! -L "$baseline" ] || fail "invalid baseline: $baseline"
    [ -f "$current" ] && [ ! -L "$current" ] || fail "invalid current file: $current"
    cp -p "$baseline" "$work_dir/cpan$id.baseline.nft"
    cp -p "$current" "$work_dir/cpan$id.before.nft"
    perl "$script_dir/prepare-host-ssh.pl" --vm-id "$id" \
        --input "$work_dir/cpan$id.baseline.nft" --output "$work_dir/cpan$id.next.nft"
    if ! cmp -s "$work_dir/cpan$id.before.nft" "$work_dir/cpan$id.baseline.nft" &&
       ! cmp -s "$work_dir/cpan$id.before.nft" "$work_dir/cpan$id.next.nft"; then
        fail "VM $id differs from the baseline and candidate; no files replaced"
    fi
    diff_rc=0
    diff -u "$work_dir/cpan$id.before.nft" "$work_dir/cpan$id.next.nft" || diff_rc=$?
    [ "$diff_rc" -le 1 ] || fail "cannot compare VM $id"
    timeout --kill-after=2 10 nft --check --file "$work_dir/cpan$id.next.nft"
done

if [ "$apply" -eq 0 ]; then
    printf '%s\n' 'PLAN_ONLY: original configuration files unchanged; use --apply to install.'
    exit 0
fi

# Refuse changes made during validation. Keep both pre-install files in work_dir.
for id in 151 152; do
    current=$config_dir/cpan$id.nft
    [ -f "$current" ] && [ ! -L "$current" ] || fail "current file changed: $current"
    cmp -s "$current" "$work_dir/cpan$id.before.nft" || fail "VM $id changed during validation"
done
for id in 151 152; do
    current=$config_dir/cpan$id.nft
    if cmp -s "$current" "$work_dir/cpan$id.next.nft"; then
        printf 'VM %s: already current\n' "$id"
        continue
    fi
    cmp -s "$current" "$work_dir/cpan$id.before.nft" || fail "VM $id changed before replacement"
    # Each rename stays on the configuration filesystem. The two renames are
    # separate operations; retained backups permit recovery after a partial error.
    cp -p "$work_dir/cpan$id.next.nft" "$work_dir/cpan$id.install.nft"
    mv -f "$work_dir/cpan$id.install.nft" "$current"
    printf 'VM %s: installed\n' "$id"
done
for id in 151 152; do
    cmp -s "$config_dir/cpan$id.nft" "$work_dir/cpan$id.next.nft" || fail "VM $id verification failed"
done
sha256sum "$config_dir/cpan151.nft" "$config_dir/cpan152.nft"
printf '%s\n' 'PERSISTENCE_FILES_VERIFIED: live rules unchanged; reboot recovery not tested.'
