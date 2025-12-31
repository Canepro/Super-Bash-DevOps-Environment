# =========================================================
# 1. THE ENGINE: ble.sh (Must be at the very top)
# =========================================================
[[ $- == *i* ]] && source ~/.local/share/blesh/ble.sh --noattach

# ble.sh IntelliSense / Menu Settings
bleopt complete_menu_style=desc        # Shows descriptions (like the ": directory" you saw)
bleopt complete_auto_complete=1        # Predicts while typing
bleopt complete_auto_history=1         # History-based predictions
bleopt complete_menu_filter=1          # Interactive menu filtering
bleopt complete_menu_maxlines=10       # Height of the menu

# =========================================================
# 2. PATHS & EXPORTS
# =========================================================
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$HOME/bin:$PATH"
export SUPPRESS_LABEL_WARNING=True

# =========================================================
# 2.1 LOCAL OVERRIDES (Optional)
# =========================================================
# Put machine/user-specific tweaks here without modifying the repo-managed bashrc.
# Example: export POSH_THEME=... or DEV_REPOS_DIR=...
[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"

# KUBECONFIG: Use D: drive if available (WSL), otherwise use environment variable or default
if [ -f "/mnt/d/secrets/kube/config" ]; then
  export KUBECONFIG=/mnt/d/secrets/kube/config
elif [ -n "$KUBECONFIG" ]; then
  # Already set via environment variable, keep it
  :
elif [ -f "$HOME/.kube/config" ]; then
  export KUBECONFIG="$HOME/.kube/config"
fi

# =========================================================
# 3. KUBERNETES TOOLS (The "IntelliSense" Functions)
# =========================================================

# kn: Switch CLUSTER (Context)
kn() {
  if ! command -v kubectl &>/dev/null; then
    echo "Error: kubectl is not installed" >&2
    return 1
  fi
  local context
  context=$(kubectl config get-contexts -o name 2>/dev/null | fzf --height 40% --reverse --prompt="Switch Cluster Context > ")
  [ -n "$context" ] && kubectl config use-context "$context"
}

# ksn: Switch NAMESPACE
ksn() {
  if ! command -v kubectl &>/dev/null; then
    echo "Error: kubectl is not installed" >&2
    return 1
  fi
  local namespace
  namespace=$(kubectl get namespaces -o name 2>/dev/null | sed 's/namespace\///' | fzf --height 40% --reverse --prompt="Switch Namespace > ")
  [ -n "$namespace" ] && kubectl config set-context --current --namespace="$namespace"
}

# klp: Fuzzy Pod Logs (Fixed to not show directories)
klp() {
  if ! command -v kubectl &>/dev/null; then
    echo "Error: kubectl is not installed" >&2
    return 1
  fi
  local pod
  pod=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" 2>/dev/null | fzf --height 40% --reverse --prompt="Select Pod for Logs > ")
  if [ -n "$pod" ]; then
    kubectl logs -f "$pod"
  else
    echo "No pods found or selection cancelled."
  fi
}

# kxp: Fuzzy Exec into Pod
kxp() {
  if ! command -v kubectl &>/dev/null; then
    echo "Error: kubectl is not installed" >&2
    return 1
  fi
  local pod
  pod=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" 2>/dev/null | fzf --height 40% --reverse --prompt="Exec into Pod > ")
  if [ -n "$pod" ]; then
    kubectl exec -it "$pod" -- bash 2>/dev/null || kubectl exec -it "$pod" -- sh
  fi
}

# kdp: Kubernetes Describe Pod (Search across all namespaces)
kdp() {
  if ! command -v kubectl &>/dev/null; then
    echo "Error: kubectl is not installed" >&2
    return 1
  fi
  local pod_info
  pod_info=$(kubectl get pods -A --no-headers 2>/dev/null | fzf --height 40% --reverse --prompt="Describe Pod > ")
  if [ -n "$pod_info" ]; then
    # Extracts namespace ($1) and pod name ($2) from the fzf selection
    local ns=$(echo "$pod_info" | awk '{print $1}')
    local pod=$(echo "$pod_info" | awk '{print $2}')
    kubectl describe pod "$pod" -n "$ns"
  fi
}

# =========================================================
# 4. PLUGINS (fzf & zoxide)
# =========================================================
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
eval "$(zoxide init bash)"

# =========================================================
# 5. ALIASES & COMPLETIONS
# =========================================================
alias k='kubectl'
alias kgp='kubectl get pods'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'
alias b='bun'
alias br='bun run'
alias l='ls -l --color=auto'

# cdd: Quick access to repos (D: drive on WSL, or custom path)
if [ -d "/mnt/d/repos" ]; then
  alias cdd='cd /mnt/d/repos'
elif [ -n "$DEV_REPOS_DIR" ] && [ -d "$DEV_REPOS_DIR" ]; then
  alias cdd="cd $DEV_REPOS_DIR"
elif [ -d "$HOME/repos" ]; then
  alias cdd='cd $HOME/repos'
fi

# Advanced Completions
if command -v kubectl &>/dev/null; then
  source <(kubectl completion bash) 2>/dev/null
  complete -F __start_kubectl k
fi
if command -v terraform &>/dev/null; then
  complete -C "$(command -v terraform)" terraform
fi

# =========================================================
# 5.1 SYSTEM MAINTENANCE
# =========================================================
# sysupdate: One-command OS update for Debian/RHEL/Arch
# - Runs full upgrade and cleans up old packages
alias sysupdate='
  if [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove --purge -y
  elif [ -f /etc/redhat-release ]; then
    sudo dnf upgrade -y && sudo dnf autoremove -y
  elif [ -f /etc/arch-release ]; then
    sudo pacman -Syu --noconfirm
  else
    echo "Unsupported distro"
  fi
'

# sysinfo: Quick system overview (storage, memory, CPU, Docker)
alias sysinfo='
  echo "================ STORAGE ================"
  df -h / | awk "NR==1 || NR==2"
  echo ""
  echo "================ MEMORY ================="
  free -h
  echo ""
  echo "================ CPU CORES =============="
  nproc
  if command -v docker &>/dev/null; then
    echo ""
    echo "================ DOCKER USAGE ==========="
    docker system df 2>/dev/null || echo "(Docker not running)"
  fi
'

# ports: Show all listening ports with process info
alias ports='sudo ss -tulnp 2>/dev/null || sudo netstat -tulnp'

# myip: Show public IP address
alias myip='curl -s ifconfig.me && echo'

# localip: Show local IP addresses
alias localip='hostname -I 2>/dev/null || ip -4 addr show | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | grep -v "127.0.0.1"'

# pingg: Quick connectivity check (Google DNS)
alias pingg='ping -c 4 8.8.8.8'

# =========================================================
# 5.2 DOCKER SHORTCUTS
# =========================================================
# dps: Clean container list with names, status, and ports
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# dimg: List all Docker images
alias dimg='docker images'

# dprune: Remove all unused Docker resources (images, containers, volumes)
alias dprune='docker system prune -af --volumes'

# dstop: Stop all running containers
alias dstop='docker stop $(docker ps -q) 2>/dev/null || echo "No running containers"'

# dexec: Fuzzy exec into a running container (like kxp but for Docker)
dexec() {
  if ! command -v docker &>/dev/null; then
    echo "Error: docker is not installed" >&2
    return 1
  fi
  local container
  container=$(docker ps --format "{{.Names}}" 2>/dev/null | fzf --height 40% --reverse --prompt="Exec into Container > ")
  if [ -n "$container" ]; then
    docker exec -it "$container" bash 2>/dev/null || docker exec -it "$container" sh
  fi
}

# dlogs: Fuzzy container logs (like klp but for Docker)
dlogs() {
  if ! command -v docker &>/dev/null; then
    echo "Error: docker is not installed" >&2
    return 1
  fi
  local container
  container=$(docker ps -a --format "{{.Names}}" 2>/dev/null | fzf --height 40% --reverse --prompt="Select Container for Logs > ")
  if [ -n "$container" ]; then
    docker logs -f "$container"
  fi
}

# =========================================================
# 5.3 GIT SHORTCUTS
# =========================================================
# gs: Quick git status
alias gs='git status'

# gp: Git pull
alias gp='git pull'

# gpp: Git pull then push (sync with remote)
alias gpp='git pull && git push'

# glog: Recent commit history (one-line format)
alias glog='git log --oneline -20'

# gundo: Undo last commit but keep changes staged
alias gundo='git reset --soft HEAD~1'

# gd: Git diff (show unstaged changes)
alias gd='git diff'

# gds: Git diff staged (show staged changes)
alias gds='git diff --staged'

# =========================================================
# 5.4 FILE & DIRECTORY UTILITIES
# =========================================================
# ll: Detailed directory listing with human-readable sizes
alias ll='ls -alh --color=auto'

# lt: Directory listing sorted by modification time (newest first)
alias lt='ls -alht --color=auto'

# mkcd: Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# extract: Universal archive extractor
# Supports: tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <archive>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: '$1' is not a valid file"
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.zip)     unzip "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.7z)      7z x "$1" ;;
    *.Z)       uncompress "$1" ;;
    *)         echo "Error: Unknown archive format '$1'" ;;
  esac
}

# =========================================================
# 5.5 PROCESS MANAGEMENT
# =========================================================
# psg: Find processes by name (ps + grep)
psg() {
  ps aux | grep -v grep | grep -i "${1:-.}"
}

# topcpu: Show top 10 CPU-consuming processes
alias topcpu='ps aux --sort=-%cpu | head -11'

# topmem: Show top 10 memory-consuming processes
alias topmem='ps aux --sort=-%mem | head -11'

# =========================================================
# 6. EXTERNAL TOOLS (NVM, OCI, Envman)
# =========================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# OCI CLI autocomplete (dynamically find the script, supports any Python version)
if [ -d "$HOME/lib/oracle-cli" ]; then
  OCI_AUTOCOMPLETE=$(find "$HOME/lib/oracle-cli" -name "oci_autocomplete.sh" 2>/dev/null | head -1)
  [ -n "$OCI_AUTOCOMPLETE" ] && [ -f "$OCI_AUTOCOMPLETE" ] && source "$OCI_AUTOCOMPLETE"
fi

[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# =========================================================
# 7. VISUALS (Oh My Posh)
# =========================================================
# Prioritize custom dotfiles theme, then fall back to system/Windows defaults
if command -v oh-my-posh &> /dev/null; then
  # Allow user override via environment variable (set in ~/.bashrc.local or elsewhere).
  # Examples:
  #   export POSH_THEME="$HOME/dotfiles/jandedobbeleer.omp.json"
  #   WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
  #   export POSH_THEME="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/oh-my-posh/themes/jandedobbeleer.omp.json"

  # If POSH_THEME isn't set (or points to a missing file), pick a sensible default.
  if [ -z "${POSH_THEME:-}" ] || [ ! -f "$POSH_THEME" ]; then
    if [ -f "$HOME/dotfiles/jandedobbeleer.omp.json" ]; then
      export POSH_THEME="$HOME/dotfiles/jandedobbeleer.omp.json"
    elif [ -n "${WSL_DISTRO_NAME:-}" ] || [ -n "${WSLENV:-}" ]; then
      WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n' || echo "")
      WIN_THEME="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/oh-my-posh/themes/jandedobbeleer.omp.json"
      [ -n "$WIN_USER" ] && [ -f "$WIN_THEME" ] && export POSH_THEME="$WIN_THEME"
    fi
  fi

  # Initialize oh-my-posh using the selected theme.
  # Using `source <(...)` is more robust than eval across oh-my-posh versions and caching behavior.
  if [ -n "${POSH_THEME:-}" ] && [ -f "$POSH_THEME" ]; then
    source <(oh-my-posh init bash --config "$POSH_THEME")
  else
    source <(oh-my-posh init bash)
  fi
fi

# =========================================================
# 8. ATTACH ble.sh (Bottom)
# =========================================================
[[ $- == *i* ]] && ble-attach
