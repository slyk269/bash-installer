#!/usr/bin/env bash
# install.sh - install a basic development environment on Debian/Ubuntu.
#
# Usage: ./install.sh [--dry-run]
#   --dry-run   print the commands instead of running them

set -euo pipefail

PACKAGES=(git curl wget build-essential python3 python3-pip python3-venv vim tree)
DRY_RUN=0

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=1
fi

run() {
    if (( DRY_RUN )); then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

log() { echo "==> $*"; }

if (( ! DRY_RUN )) && [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "error: apt-get not found; this script supports Debian/Ubuntu only." >&2
    exit 1
fi

log "Updating package list..."
run $SUDO apt-get update -y

log "Installing: ${PACKAGES[*]}"
run $SUDO apt-get install -y "${PACKAGES[@]}"

log "Verifying installation..."
for tool in git curl python3; do
    if (( DRY_RUN )); then
        echo "[dry-run] would check for $tool"
    elif command -v "$tool" >/dev/null 2>&1; then
        echo "  ok: $tool ($("$tool" --version 2>&1 | head -n1))"
    else
        echo "  missing: $tool" >&2
        exit 1
    fi
done

log "Done."
