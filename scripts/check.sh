#!/usr/bin/env bash
# Evaluates every machine, image and dev shell. Evaluation catches option
# typos, missing packages, priority conflicts and failed assertions, which is
# nearly every mistake a config change can make, in a minute and for free.
# Building is separate: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
check() {
  local label=$1 attr=$2 out
  if out=$(nix eval --no-write-lock-file --raw ".#$attr" 2>&1); then
    printf '  \033[32m✓\033[0m %s\n' "$label"
  else
    printf '  \033[31m✗\033[0m %s\n' "$label"; echo "$out" | tail -15 | sed 's/^/      /'; fail=1
  fi
}
echo "Machines"
for h in $(nix eval --no-write-lock-file --json .#nixosConfigurations --apply builtins.attrNames | tr -d '[]"' | tr , ' '); do
  check "$h" "nixosConfigurations.$h.config.system.build.toplevel.drvPath"
done
echo "Images"
for p in usb-dev-x86 usb-dev-x86-cuda vm-x86-disk adsdv-image installer-iso adsdv-sim-vm; do
  check "$p" "packages.x86_64-linux.$p.drvPath"
done
for p in vm-aarch64-disk; do
  check "$p" "packages.aarch64-linux.$p.drvPath"
done
echo "Dev shells"
for s in x86_64-linux aarch64-linux aarch64-darwin; do
  for n in $(nix eval --no-write-lock-file --json ".#devShells.$s" --apply builtins.attrNames | tr -d '[]"' | tr , ' '); do
    check "$s $n" "devShells.$s.$n.drvPath"
  done
done
echo "Member template"
check "template" "templates.member.path"
exit $fail
