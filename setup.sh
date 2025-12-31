#!/bin/bash
# setup.sh - Automated Super-Bash Installer
# This script installs and configures your Super-Bash DevOps Environment

set -euo pipefail  # Exit on any error/unset var; fail pipelines

echo "=========================================="
echo "🚀 Super-Bash DevOps Environment Setup"
echo "=========================================="
echo ""

# Resolve repo directory so the script can be run from anywhere
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v git >/dev/null 2>&1 || { echo "❌ Error: git is required but not installed."; exit 1; }
command -v make >/dev/null 2>&1 || { echo "❌ Error: make is required but not installed."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "❌ Error: curl is required but not installed."; exit 1; }
echo "✅ All prerequisites found!"
echo ""

# Backup existing .bashrc (timestamped) before overwriting
if [ -f "$HOME/.bashrc" ]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  echo "💾 Backing up existing .bashrc to ~/.bashrc.backup.${TS}..."
  cp "$HOME/.bashrc" "$HOME/.bashrc.backup.${TS}"
fi

echo "🚀 Installing tools..."
echo ""

# Install ble.sh
echo "  1/5 Installing ble.sh (Bash IntelliSense)..."
BLE_TMP="$(mktemp -d)"
BLE_LOG="$(mktemp)"
if (
  cd "$BLE_TMP"
  if ! git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git > "$BLE_LOG" 2>&1; then
    echo "     ❌ Error: Failed to clone ble.sh repository" >&2
    cat "$BLE_LOG" >&2
    exit 1
  fi
  if ! make -C ble.sh install PREFIX="$HOME/.local" > "$BLE_LOG" 2>&1; then
    echo "     ❌ Error: Failed to build/install ble.sh" >&2
    cat "$BLE_LOG" >&2
    exit 1
  fi
); then
  echo "     ✅ ble.sh installed"
else
  echo "     ❌ ble.sh installation failed. Check errors above."
  rm -rf "$BLE_TMP" "$BLE_LOG"
  exit 1
fi
rm -rf "$BLE_TMP" "$BLE_LOG"

# Install fzf
echo "  2/5 Installing fzf (fuzzy finder)..."
FZF_LOG="$(mktemp)"
if [ -d "$HOME/.fzf/.git" ]; then
  if ! (cd "$HOME/.fzf" && git pull > "$FZF_LOG" 2>&1); then
    echo "     ⚠️  Warning: Failed to update fzf (continuing with existing installation)" >&2
    cat "$FZF_LOG" >&2
  fi
else
  if ! git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" > "$FZF_LOG" 2>&1; then
    echo "     ❌ Error: Failed to clone fzf repository" >&2
    cat "$FZF_LOG" >&2
    rm -f "$FZF_LOG"
    exit 1
  fi
fi
if ! "$HOME/.fzf/install" --all --no-update-rc > "$FZF_LOG" 2>&1; then
  echo "     ⚠️  Warning: fzf install script had issues (fzf may still work)" >&2
  cat "$FZF_LOG" >&2
else
  echo "     ✅ fzf installed"
fi
rm -f "$FZF_LOG"

# Install zoxide
echo "  3/5 Installing zoxide (smart cd)..."
ZOXIDE_LOG="$(mktemp)"
if ! curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash > "$ZOXIDE_LOG" 2>&1; then
  echo "     ❌ Error: Failed to install zoxide" >&2
  cat "$ZOXIDE_LOG" >&2
  rm -f "$ZOXIDE_LOG"
  exit 1
fi
echo "     ✅ zoxide installed"
rm -f "$ZOXIDE_LOG"

# Install Bun
echo "  4/5 Installing Bun (JavaScript runtime)..."
BUN_PREREQ_MISSING=false
if ! command -v unzip >/dev/null 2>&1; then
  echo "     ❌ Error: unzip is required to install Bun (missing 'unzip' command)" >&2
  echo "        Ubuntu/Debian: sudo apt update && sudo apt install -y unzip" >&2
  BUN_PREREQ_MISSING=true
fi
if [ "$BUN_PREREQ_MISSING" = true ]; then
  exit 1
fi
BUN_LOG="$(mktemp)"
if ! curl -fsSL https://bun.sh/install | bash > "$BUN_LOG" 2>&1; then
  echo "     ❌ Error: Failed to install Bun" >&2
  cat "$BUN_LOG" >&2
  rm -f "$BUN_LOG"
  exit 1
fi
echo "     ✅ Bun installed"
rm -f "$BUN_LOG"
echo ""

# Install Oh My Posh (Linux/WSL side)
echo "  5/5 Installing oh-my-posh (prompt)..."
OMP_LOG="$(mktemp)"
mkdir -p "$HOME/.local/bin"
if command -v oh-my-posh >/dev/null 2>&1; then
  echo "     ✅ oh-my-posh already installed ($(oh-my-posh --version 2>/dev/null || echo "version unknown"))"
else
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) omp_asset="posh-linux-amd64" ;;
    aarch64|arm64) omp_asset="posh-linux-arm64" ;;
    *)
      echo "     ⚠️  Warning: Unsupported architecture for automatic oh-my-posh install: $arch" >&2
      echo "        Install manually: https://ohmyposh.dev/docs/installation/linux" >&2
      omp_asset=""
      ;;
  esac

  if [ -n "$omp_asset" ]; then
    omp_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/${omp_asset}"
    if ! curl -fsSL "$omp_url" -o "$HOME/.local/bin/oh-my-posh" > "$OMP_LOG" 2>&1; then
      echo "     ❌ Error: Failed to download oh-my-posh from GitHub releases" >&2
      cat "$OMP_LOG" >&2
      rm -f "$OMP_LOG"
      exit 1
    fi
    chmod +x "$HOME/.local/bin/oh-my-posh"
    echo "     ✅ oh-my-posh installed ($("$HOME/.local/bin/oh-my-posh" --version 2>/dev/null || echo "version unknown"))"
  fi
fi
rm -f "$OMP_LOG"
echo ""

echo "📂 Configuring dotfiles..."
mkdir -p "$HOME/dotfiles"
cp "$REPO_DIR/dotfiles/.bashrc" "$HOME/.bashrc"
cp "$REPO_DIR/dotfiles/jandedobbeleer.omp.json" "$HOME/dotfiles/jandedobbeleer.omp.json"
echo "✅ Configuration files copied"
echo ""

echo "=========================================="
echo "✅ Setup complete!"
echo "=========================================="
echo ""
echo "📝 IMPORTANT: Please restart your terminal to activate the new environment."
echo ""
echo "   Close this terminal and open a new one to see the changes."
echo ""

