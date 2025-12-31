#!/usr/bin/env bash
# bootstrap.sh - one-command installer/updater for Super-Bash-DevOps-Environment
#
# Supports two modes:
# 1) Run from inside an existing clone (this file sits next to setup.sh) -> just runs setup.sh
# 2) Run from anywhere (or via curl|bash) -> clones/updates repo, then runs setup.sh
#
# Non-interactive by default: if repo URL is required and not provided, exits with instructions.

set -euo pipefail

print_usage() {
  cat <<'EOF'
Usage:
  # If running outside the repo (recommended for first-time install):
  SUPER_BASH_REPO_URL="https://github.com/<ORG>/<REPO>.git" bash -c "$(curl -fsSL <raw-bootstrap-url>)"

  # Optional overrides:
  SUPER_BASH_INSTALL_DIR="/some/path/Super-Bash-DevOps-Environment"
  SUPER_BASH_BRANCH="<branch>"

  # If running from inside the repo:
  bash bootstrap.sh

Env vars:
  SUPER_BASH_REPO_URL     Required when not running inside an existing clone.
  SUPER_BASH_INSTALL_DIR  Optional. Defaults to:
                          - /mnt/d/repos/Super-Bash-DevOps-Environment if /mnt/d/repos exists (WSL)
                          - $HOME/repos/Super-Bash-DevOps-Environment otherwise
  SUPER_BASH_BRANCH       Optional. Defaults to the remote default branch (auto-detected), else "master", else "main"
EOF
}

log() { printf '%s\n' "$*"; }
err() { printf '%s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "❌ Error: required command not found: $1"
    exit 1
  fi
}

install_prereq_hint() {
  err ""
  err "Install missing prerequisites, then re-run bootstrap."
  if command -v apt >/dev/null 2>&1; then
    err ""
    err "Ubuntu/Debian:"
    err "  sudo apt update"
    err "  sudo apt install -y git make curl build-essential"
  elif command -v dnf >/dev/null 2>&1; then
    err ""
    err "RHEL/Fedora:"
    err "  sudo dnf install -y git make curl gcc gcc-c++"
  elif command -v yum >/dev/null 2>&1; then
    err ""
    err "RHEL/CentOS:"
    err "  sudo yum install -y git make curl gcc gcc-c++"
  fi
}

run_setup_in_dir() {
  local dir="$1"
  log "✅ Detected local repo clone at: $dir"
  require_cmd make
  log "▶ Running setup.sh..."
  (cd "$dir" && bash setup.sh)
  log "🧹 Clearing oh-my-posh cache..."
  rm -rf "$HOME/.cache/oh-my-posh" 2>/dev/null || true
  log "✅ Done. Restart your terminal (recommended), or run: source ~/.bashrc"
}

# If we're already in a repo clone (e.g., user ran `bash bootstrap.sh` inside repo),
# run setup.sh from the repo root.
if [ -f "./setup.sh" ] && [ -f "./bootstrap.sh" ]; then
  run_setup_in_dir "$(pwd)"
  exit 0
fi

# If we are inside a git worktree somewhere under the repo, locate root and run.
if command -v git >/dev/null 2>&1; then
  if repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    if [ -f "$repo_root/setup.sh" ] && [ -f "$repo_root/bootstrap.sh" ]; then
      run_setup_in_dir "$repo_root"
      exit 0
    fi
  fi
fi

# Otherwise we need to clone/update.
require_cmd git
require_cmd curl
require_cmd bash
if ! command -v make >/dev/null 2>&1; then
  err "❌ Error: make is required but not installed."
  install_prereq_hint
  exit 1
fi
if ! command -v unzip >/dev/null 2>&1; then
  err "❌ Error: unzip is required but not installed."
  install_prereq_hint
  exit 1
fi

detect_default_branch() {
  # Try to read remote default branch (HEAD) without cloning.
  # Output format:
  #   ref: refs/heads/<branch>    HEAD
  local url="$1"
  local ref
  ref="$(git ls-remote --symref "$url" HEAD 2>/dev/null | awk '/^ref:/ {print $2; exit}')"
  if [[ -n "${ref:-}" && "$ref" == refs/heads/* ]]; then
    echo "${ref#refs/heads/}"
    return 0
  fi
  return 1
}

if [ -z "${SUPER_BASH_INSTALL_DIR:-}" ]; then
  if [ -d "/mnt/d/repos" ]; then
    SUPER_BASH_INSTALL_DIR="/mnt/d/repos/Super-Bash-DevOps-Environment"
  else
    SUPER_BASH_INSTALL_DIR="$HOME/repos/Super-Bash-DevOps-Environment"
  fi
fi

if [ -z "${SUPER_BASH_REPO_URL:-}" ]; then
  err "❌ Error: SUPER_BASH_REPO_URL is required when running bootstrap outside the repo."
  err ""
  print_usage
  exit 2
fi

if [ -z "${SUPER_BASH_BRANCH:-}" ]; then
  SUPER_BASH_BRANCH="$(detect_default_branch "$SUPER_BASH_REPO_URL" || true)"
fi
SUPER_BASH_BRANCH="${SUPER_BASH_BRANCH:-master}"
if [ -z "${SUPER_BASH_BRANCH:-}" ]; then
  SUPER_BASH_BRANCH="main"
fi

log "📦 Installing/updating Super-Bash DevOps Environment"
log "   Repo:   $SUPER_BASH_REPO_URL"
log "   Branch: $SUPER_BASH_BRANCH"
log "   Path:   $SUPER_BASH_INSTALL_DIR"
log ""

PARENT_DIR="$(dirname "$SUPER_BASH_INSTALL_DIR")"
mkdir -p "$PARENT_DIR"

if [ -d "$SUPER_BASH_INSTALL_DIR/.git" ]; then
  log "🔄 Existing clone found. Updating..."
  (cd "$SUPER_BASH_INSTALL_DIR" && git fetch --all --prune && git checkout "$SUPER_BASH_BRANCH" && git pull --ff-only)
else
  log "⬇ Cloning repo..."
  git clone --depth 1 --branch "$SUPER_BASH_BRANCH" "$SUPER_BASH_REPO_URL" "$SUPER_BASH_INSTALL_DIR"
fi

log "▶ Running setup.sh..."
(cd "$SUPER_BASH_INSTALL_DIR" && bash setup.sh)

log "🧹 Clearing oh-my-posh cache..."
rm -rf "$HOME/.cache/oh-my-posh" 2>/dev/null || true

log ""
log "✅ Bootstrap complete."
log "Next:"
log "  - Restart your terminal (recommended), or run: source ~/.bashrc"
log "  - Run: bash check_setup.sh"

