# Super-Bash DevOps Environment

A reproducible suite of configuration files for a Bash environment that mimics Fish/Zsh features with modern tooling and Kubernetes integration. Works on **WSL (Windows)**, **Linux VMs**, and **remote machines**.

## ✨ Summary of Capabilities

Your "Super-Bash" environment provides:

- 🧠 **IntelliSense**: ble.sh providing real-time syntax highlighting and interactive menus
- ☸️ **Kubernetes**: `kn` (context), `ksn` (namespace), and `klp` (logs) all fuzzy-powered with fzf
- 🐳 **Docker**: Fuzzy exec (`dexec`), logs (`dlogs`), and quick management aliases
- 🔧 **System**: One-command OS updates (`sysupdate`), system info (`sysinfo`), and process tools
- ⚡ **Bun**: Prompt and paths optimized for the Bun JavaScript runtime
- 🎨 **Visuals**: Oh My Posh handles your OCI/OKE/Production color-coding perfectly
- 🔍 **Fuzzy Finding**: fzf integration for files, commands, and history
- 📁 **Smart Navigation**: zoxide for intelligent directory jumping
- 🔀 **Git**: Quick shortcuts for status, pull, push, and history

---

## 🔗 Related Projects

**For Windows users:** If you're working on Windows (not WSL) and prefer PowerShell, check out [portable-lab-setup](https://github.com/Canepro/portable-lab-setup) - a complementary PowerShell-based DevOps environment with similar Kubernetes tooling and a portable installation approach.

Both repositories follow the same philosophy:

- ✅ Portable and reproducible setups
- ✅ Kubernetes-first workflow optimizations
- ✅ No administrator privileges required
- ✅ Idempotent installation scripts

---

## 📑 Table of Contents

- [🚀 Installation (Step-by-Step)](#-installation-step-by-step)
- [🎯 Quick Reference](#-quick-reference)
- [📦 What Gets Installed](#-what-gets-installed)
- [⌨️ Keyboard Shortcuts & Workflow](#️-keyboard-shortcuts--workflow)
- [⚙️ Configuration](#️-configuration)
- [🩺 Health Check Script](#-health-check-script)
- [🐛 Troubleshooting Common Issues](#-troubleshooting-common-issues)
- [🎯 Environment-Specific Setup](#-environment-specific-setup)
- [🔄 Updating](#-updating)

---

## 🚀 Installation (Step-by-Step)

### Step 1: Check Prerequisites

Before you start, make sure you have these installed:

- ✅ **Git** - Check with: `git --version`
- ✅ **Make** - Check with: `make --version`
- ✅ **curl** - Check with: `curl --version`
- ✅ **Bash** (version 4.0+) - Check with: `bash --version`

If any are missing, install them first using your system's package manager.

**Ubuntu/Debian quick install:**

```bash
sudo apt update
sudo apt install -y git make curl build-essential unzip
```

**Tip:** The bash version command is `bash --version` (double-dash). If you type `bash --versio` you’ll get an “invalid option” error.

### Step 2: Clone or Navigate to This Repository

**If this is a new machine:**

```bash
git clone https://github.com/Canepro/Super-Bash-DevOps-Environment.git Super-Bash-DevOps-Environment
cd Super-Bash-DevOps-Environment
```

**If you already have the repo:**

```bash
cd Super-Bash-DevOps-Environment
```

*(This repo is available at `https://github.com/Canepro/Super-Bash-DevOps-Environment`.)*

### Step 3: Run the Setup Script

```bash
bash setup.sh
```

**What happens during setup:**

1. 🚀 Installs ble.sh (Bash IntelliSense)
2. 🚀 Installs fzf (fuzzy finder)
3. 🚀 Installs zoxide (smart directory navigation)
4. 🚀 Installs Bun (JavaScript runtime)
5. 🚀 Installs oh-my-posh (prompt engine) to `~/.local/bin` (Linux/WSL side)
6. 📂 Copies configuration files to your home directory
7. 💾 Backs up your existing `~/.bashrc` (timestamped) before overwriting it

**Expected time:** 2-5 minutes (depending on internet speed)

**Safe to re-run:** Yes. `setup.sh` is designed to be idempotent:

- Re-running updates existing installs when possible (e.g., `fzf` pulls latest)
- Re-running always creates a new backup: `~/.bashrc.backup.YYYYMMDD-HHMMSS`

### Step 4: Restart Your Terminal

**Important:** Close and reopen your terminal to activate the new environment.

You'll know it worked when you see:

- ✨ A colorful prompt (oh-my-posh theme)
- ✨ Enhanced tab completion with descriptions
- ✨ All the new aliases and functions available

### Step 5: Run Health Check

Verify that everything is installed correctly:

```bash
bash check_setup.sh
```

This will check:

- ✅ All core engines (fzf, zoxide, bun, ble.sh)
- ✅ DevOps tools (kubectl, OCI CLI)
- ✅ Bun runtime configuration
- ✅ oh-my-posh theme availability
- ✅ Custom functions (kn, ksn, klp, kxp, kdp)
- ✅ Configuration files

**Expected output:** Green checkmarks (✓) for installed components, warnings (⚠) for optional items.

### Step 6: Verify Installation Manually (Optional)

You can also test manually:

```bash
# Test aliases
k --help          # Should show kubectl help
b --version       # Should show Bun version

# Test functions (if kubectl is installed)
kn                # Should show cluster selection menu

# Check if tools are installed
which fzf         # Should show path to fzf
which zoxide      # Should show path to zoxide
```

---

## 🎯 Quick Reference

**Just need a reminder?** Here's the one-liner:

```bash
cd Super-Bash-DevOps-Environment && bash setup.sh && echo "✅ Done! Restart your terminal."
```

**Run health check after installation:**

```bash
bash ./check_setup.sh
```

### 🚀 Bootstrap (One-Command Install/Update)

If you want a single entrypoint that **clones/updates** this repo and runs `setup.sh`, use `bootstrap.sh`.

- **Note:** `bootstrap.sh` still requires the same prerequisites as `setup.sh` (`git`, `make`, `curl`, `bash`). If something is missing, it will stop and tell you what to install.

- **Recommended (curl | bash)**: set your repo URL and run:

```bash
SUPER_BASH_REPO_URL="https://github.com/Canepro/Super-Bash-DevOps-Environment.git" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Canepro/Super-Bash-DevOps-Environment/master/bootstrap.sh)"
```

- **If you already cloned the repo**:

```bash
bash bootstrap.sh
```

**Where it installs by default:**

- **WSL**: `/mnt/d/repos/Super-Bash-DevOps-Environment` (if `/mnt/d/repos` exists)
- **Linux**: `~/repos/Super-Bash-DevOps-Environment`

**Optional overrides:**

```bash
SUPER_BASH_INSTALL_DIR="/some/path/Super-Bash-DevOps-Environment" SUPER_BASH_REPO_URL="https://github.com/Canepro/Super-Bash-DevOps-Environment.git" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Canepro/Super-Bash-DevOps-Environment/master/bootstrap.sh)"
```

### 🚀 One-Step Install (Private Repo Friendly)

If you want a single command to install from your **private** GitHub repo:

```bash
git clone https://github.com/Canepro/Super-Bash-DevOps-Environment.git Super-Bash-DevOps-Environment && cd Super-Bash-DevOps-Environment && bash setup.sh
```

Note: If you fork this repo, replace the URL with your fork.

## 📦 What Gets Installed

### Core Engines

- **ble.sh** - Bash Line Editor with IntelliSense-like features
- **fzf** - Fuzzy finder for command-line
- **zoxide** - Smarter `cd` command
- **Bun** - Fast JavaScript runtime and package manager
- **oh-my-posh** - Prompt engine (installed to `~/.local/bin` on Linux/WSL)

### Features

#### IntelliSense-like Completions

- Auto-complete with descriptions
- Menu-style completion
- History-based suggestions

#### Kubernetes Integration

- `kn` - Interactive cluster switcher (fzf-powered)
- `ksn` - Interactive namespace switcher (fzf-powered)
- `klp` - Interactive pod log viewer (fzf-powered)
- `kxp` - Interactive exec into pod (fzf-powered)
- `kdp` - Interactive describe pod across all namespaces (fzf-powered)
- `k`, `kgp`, `kl`, `kx` - Short aliases for kubectl commands
- Full kubectl tab completion

#### Smart Navigation

- `zoxide` for intelligent directory jumping
- `fzf` for fuzzy finding files and commands
- Custom aliases for common paths

#### Docker Integration

- `dexec` - Interactive exec into container (fzf-powered)
- `dlogs` - Interactive container log viewer (fzf-powered)
- `dps`, `dimg`, `dprune`, `dstop` - Quick Docker aliases

#### System & DevOps Tools

- `sysupdate` - One-command OS update (Debian/RHEL/Arch)
- `sysinfo` - Quick system overview (storage, memory, CPU, Docker)
- `ports`, `myip`, `localip` - Network diagnostics
- `topcpu`, `topmem`, `psg` - Process management
- Git shortcuts: `gs`, `gp`, `gpp`, `glog`, `gundo`
- File utilities: `ll`, `lt`, `mkcd`, `extract`

#### Visual Prompt

- **oh-my-posh** theme with:
  - User session indicator
  - Current path
  - Git status
  - Bun version
  - Kubernetes context/namespace (with color coding for prod/oke)
  - Command execution time

## ⌨️ Keyboard Shortcuts & Workflow

Once installed, these shortcuts will transform your terminal workflow:

| Shortcut | Action |
| -------- | ------ |
| **Tab** (once) | Opens the Interactive IntelliSense Menu. Use arrow keys to navigate and start typing to filter results in real-time. |
| **Right Arrow** | Accepts the Ghost Suggestion (Fish-style gray text) based on your command history. |
| **Ctrl + R** | Opens a Fuzzy History Search. Type any part of a previous command to find it instantly. |
| **Alt + C** | Teleport to Directory. Opens a fuzzy list of your most-visited folders (zoxide-powered). |
| **Ctrl + T** | Fuzzy File Finder. Search for any file in the current tree and paste its path into your command (fzf-powered). |

### Workflow Examples

**Quick Kubernetes Context Switch:**

```bash
kn    # Opens fuzzy menu to select cluster context
ksn   # Opens fuzzy menu to select namespace
klp   # Opens fuzzy menu to select pod and stream logs
```

**Docker Container Management:**

```bash
dexec  # Opens fuzzy menu to exec into a container
dlogs  # Opens fuzzy menu to follow container logs
dps    # Quick overview of running containers
dprune # Clean up all unused Docker resources
```

**System Maintenance:**

```bash
sysupdate  # Full OS update (works on Debian/RHEL/Arch)
sysinfo    # Quick overview: storage, memory, CPU, Docker
ports      # See what's listening on your machine
myip       # Show your public IP
```

**Git Workflow:**

```bash
gs     # Quick status check
gp     # Pull latest changes
gpp    # Sync: pull then push
glog   # See recent commits
gundo  # Oops, undo last commit (keeps changes)
```

**Smart Directory Navigation:**

```bash
z <partial-name>  # Jump to any recently visited directory (zoxide)
cdd               # Quick access to your repos directory
mkcd newproject   # Create and enter a new directory
```

**File & Process Management:**

```bash
ll              # Detailed directory listing
lt              # List files by modification time
extract file.tar.gz  # Universal archive extractor
psg nginx       # Find processes matching "nginx"
topcpu          # See top CPU-consuming processes
topmem          # See top memory-consuming processes
```

**Command History Search:**

- Press `Ctrl + R` and type any part of a previous command
- Keep pressing `Ctrl + R` to cycle through matches
- Press `Enter` to execute or `Tab` to edit

## 📁 File Structure

```text
.
├── setup.sh                          # Main installer script
├── check_setup.sh                    # Health check validator
├── dotfiles/
│   ├── .bashrc                       # Bash configuration
│   └── jandedobbeleer.omp.json       # oh-my-posh theme
└── README.md                         # This file
```

## ⚙️ Configuration

### Environment Variables

**Auto-detected (no configuration needed):**

- `KUBECONFIG` - Auto-detects: `/mnt/d/secrets/kube/config` (WSL), `$KUBECONFIG` (if set), or `~/.kube/config`
- `BUN_INSTALL` - Bun installation directory (`~/.bun`)
- `SUPPRESS_LABEL_WARNING` - Suppresses Kubernetes label warnings

**Optional (for VMs/remote machines):**

- `DEV_REPOS_DIR` - Custom path for `cdd` alias (defaults to `/mnt/d/repos` on WSL or `~/repos`)

### Aliases

#### Kubernetes

| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | Short kubectl |
| `kgp` | `kubectl get pods` | List pods |
| `kl` | `kubectl logs -f` | Follow pod logs |
| `kx` | `kubectl exec -it` | Exec into pod |

#### Docker

| Alias | Command | Description |
|-------|---------|-------------|
| `dps` | `docker ps --format ...` | Clean container list |
| `dimg` | `docker images` | List images |
| `dprune` | `docker system prune -af --volumes` | Remove all unused resources |
| `dstop` | `docker stop $(docker ps -q)` | Stop all running containers |

#### System Maintenance

| Alias | Description |
|-------|-------------|
| `sysupdate` | One-command OS update (Debian/RHEL/Arch) |
| `sysinfo` | Quick overview: storage, memory, CPU, Docker usage |
| `ports` | Show all listening ports with process info |
| `myip` | Show public IP address |
| `localip` | Show local IP addresses |
| `pingg` | Quick connectivity check (ping 8.8.8.8) |

#### Git

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Quick status |
| `gp` | `git pull` | Pull from remote |
| `gpp` | `git pull && git push` | Sync with remote |
| `glog` | `git log --oneline -20` | Recent commits |
| `gundo` | `git reset --soft HEAD~1` | Undo last commit (keep changes) |
| `gd` | `git diff` | Show unstaged changes |
| `gds` | `git diff --staged` | Show staged changes |

#### File & Directory

| Alias | Command | Description |
|-------|---------|-------------|
| `l` | `ls -l --color=auto` | List with colors |
| `ll` | `ls -alh --color=auto` | Detailed listing |
| `lt` | `ls -alht --color=auto` | Sorted by time |
| `cdd` | `cd <repos>` | Jump to repos directory |
| `b` | `bun` | Short for bun |
| `br` | `bun run` | Run bun scripts |

#### Process Management

| Alias | Description |
|-------|-------------|
| `topcpu` | Top 10 CPU-consuming processes |
| `topmem` | Top 10 memory-consuming processes |

### Custom Functions

#### Kubernetes (fzf-powered)

| Function | Description |
|----------|-------------|
| `kn` | Switch Kubernetes context interactively |
| `ksn` | Switch Kubernetes namespace interactively |
| `klp` | Follow logs for a pod interactively |
| `kxp` | Exec into a pod interactively (tries bash, falls back to sh) |
| `kdp` | Describe a pod interactively (searches across all namespaces) |

#### Docker (fzf-powered)

| Function | Description |
|----------|-------------|
| `dexec` | Exec into a running container interactively |
| `dlogs` | Follow container logs interactively |

#### Utilities

| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create directory and cd into it |
| `extract <file>` | Universal archive extractor (tar/zip/gz/bz2/7z/rar) |
| `psg <pattern>` | Find processes by name (ps + grep) |

## 🎨 Theme Customization

The oh-my-posh theme is configured in `dotfiles/jandedobbeleer.omp.json`. You can customize:

- Colors and styling
- Segment order and visibility
- Conditional background colors (e.g., red for prod contexts)

**Multi-Environment Support**: the theme is selected automatically in `~/.bashrc`:

- **Primary (recommended)**: `~/dotfiles/jandedobbeleer.omp.json` (copied by `setup.sh`)
- **Fallback (WSL only)**: Windows-installed theme under `/mnt/c/Users/<WindowsUser>/AppData/Local/Programs/oh-my-posh/themes/...`
- **Fallback (anywhere)**: oh-my-posh default theme if no config is found

### Overriding the Theme (Recommended)

If you want to swap themes without modifying this repo, create `~/.bashrc.local` and set `POSH_THEME`:

```bash
# ~/.bashrc.local
export POSH_THEME="$HOME/dotfiles/jandedobbeleer.omp.json"

# Example (WSL): use Windows installed theme
# WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
# export POSH_THEME="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/oh-my-posh/themes/jandedobbeleer.omp.json"
```

Then reload:

```bash
rm -rf ~/.cache/oh-my-posh
source ~/.bashrc
```

## 🔧 Prerequisites Explained

### Required (Must Have)

These are needed for the setup script to run:

| Tool | How to Check | How to Install (Ubuntu/Debian) |
| ---- | ------------ | -------------------------------- |
| **Git** | `git --version` | `sudo apt update && sudo apt install git` |
| **Make** | `make --version` | `sudo apt install build-essential` |
| **curl** | `curl --version` | `sudo apt install curl` |
| **Bash** | `bash --version` | Usually pre-installed |

### Optional (For Full Features)

These enhance the experience but aren't required for basic setup:

- **kubectl** - For Kubernetes features (install from [kubectl docs](https://kubernetes.io/docs/tasks/tools/))
- **Nerd Font** - Required for prompt icons/glyphs (see [oh-my-posh fonts docs](https://ohmyposh.dev/docs/installation/fonts))
- **WSL** - Only needed if you're using Windows Subsystem for Linux

## 📝 Notes

### Multi-Environment Support

This setup works across different environments:

- **Personal PC (WSL)**: Uses D: drive paths (`/mnt/d/`) when available
- **VMs / Remote Machines**: Automatically falls back to Linux-native paths
- **Path Detection**: All Windows-specific paths are conditional and only used if they exist

**How it works:**

- The `.bashrc` checks for path existence before using Windows/WSL-specific locations
- Falls back gracefully to Linux-standard paths (`~/.kube/config`, `~/repos`, etc.)
- Theme file is copied to `~/dotfiles/` for use on non-WSL systems

### Other Notes

- The setup script installs tools to `~/.local` and user directories
- ble.sh provides Fish/Zsh-like features in pure Bash
- All completions are sourced automatically
- **All paths are parameterized** using `$HOME` for multi-user compatibility
- The prompt shows Kubernetes context/namespace with color coding:
  - Red background for contexts containing "prod"
  - Teal background for contexts containing "oke"
- External tools (NVM, OCI CLI, envman) are auto-sourced if present

## 🩺 Health Check Script

The `check_setup.sh` script validates your entire Super-Bash environment installation. Run it anytime to verify everything is working correctly:

```bash
bash /path/to/Super-Bash-DevOps-Environment/check_setup.sh
```

### What It Checks

- **Core Engines**: fzf, zoxide, bun, ble.sh installation and cache
- **DevOps Tools**: kubectl, OCI CLI, KUBECONFIG validity
- **Bun Runtime**: PATH configuration and installation directory
- **Visuals**: oh-my-posh installation and theme file availability
- **Custom Functions**: kn, ksn, klp, kxp, kdp function availability (validated via an interactive `bash -ic`, so results match a real terminal session)
- **Configuration Files**: .bashrc and theme JSON file presence

### Understanding the Output

- **✓ OK** (Green): Component is installed and working correctly
- **⚠ MISSING/INFO** (Yellow): Optional component or informational message
- **✗ FAIL** (Red): Required component is missing or misconfigured

**Tip:** If functions show as FAIL, confirm your `~/.bashrc` is present and try:

```bash
source ~/.bashrc
```

## 🐛 Troubleshooting Common Issues

### ❌ "Command not found" errors during setup

**Problem:** Missing prerequisites

**Solution:**

```bash
# Install missing tools (Ubuntu/Debian)
sudo apt update
sudo apt install git make curl build-essential
```

### ❌ Theme not showing (plain prompt)

**Problem:** oh-my-posh not installed or theme path incorrect

**Solutions:**

- **WSL (Windows)**: Install oh-my-posh on the Windows side
- **Linux VM/Remote**: Install oh-my-posh on Linux:

```bash
# Install oh-my-posh on Linux
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
```

- **Theme file**: The theme is copied to `~/dotfiles/` and `.bashrc` will use it automatically

**If you see `CONFIG ERROR`:**

```bash
rm -rf ~/.cache/oh-my-posh
source ~/.bashrc
echo "POSH_THEME=$POSH_THEME"
```

### ❌ Tab completion not working

**Problem:** ble.sh didn't attach properly

**Solution:**

```bash
# Check if ble.sh is installed
ls ~/.local/share/blesh/ble.sh

# If missing, re-run setup or manually install:
git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
rm -rf ble.sh
```

**Then restart your terminal.**

### ❌ kubectl commands not working

**Problem:** kubectl not installed

**Solution:**

- Install kubectl from [official docs](https://kubernetes.io/docs/tasks/tools/)
- The setup doesn't install kubectl automatically (it's optional)

### ❌ "Permission denied" when running setup.sh

**Problem:** Script doesn't have execute permissions

**Solution:**

```bash
chmod +x setup.sh
bash setup.sh
```

### ✅ Everything looks broken after installation

**Don't worry!** Your original `.bashrc` is backed up automatically (if one existed).

**To restore:**

```bash
# List timestamped backups
ls -1 ~/.bashrc.backup.* 2>/dev/null

# Restore the most recent backup (example)
cp ~/.bashrc.backup.YYYYMMDD-HHMMSS ~/.bashrc
```

Or simply edit `~/.bashrc` to remove/comment out the new additions.

## 🎯 Environment-Specific Setup

### Personal PC (WSL with D: Drive) ✅

**No configuration needed!** Everything is auto-detected:

- ✅ KUBECONFIG → `/mnt/d/secrets/kube/config`
- ✅ `cdd` alias → `/mnt/d/repos`
- ✅ oh-my-posh → Windows installation path

Just run `bash setup.sh` and you're done!

### VM or Remote Linux Machine

**The setup automatically adapts!** But if you want custom paths:

#### Option 1: Use Environment Variables (Recommended)

Before running setup, or add to `~/.bashrc.local`:

```bash
# Custom kubeconfig location
export KUBECONFIG=/path/to/your/kubeconfig

# Custom repos directory
export DEV_REPOS_DIR=/path/to/your/repos
```

#### Option 2: Edit ~/.bashrc After Setup

After running setup, you can edit `~/.bashrc` to customize paths manually.

#### oh-my-posh on Linux

**Option A:** Install oh-my-posh on Linux (recommended)

```bash
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
```

**Option B:** The setup copies the theme to `~/dotfiles/` - the `.bashrc` will use it automatically

## 🔄 Updating

To update individual components:

- **fzf**: `cd ~/.fzf && git pull && ./install --all`
- **zoxide**: Re-run the install script from zoxide's repository
- **Bun**: `bun upgrade`
- **ble.sh**: Re-clone and reinstall

## 📄 License

This is a personal development environment setup. Use and modify as needed.
