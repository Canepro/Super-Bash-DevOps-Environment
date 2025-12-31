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
