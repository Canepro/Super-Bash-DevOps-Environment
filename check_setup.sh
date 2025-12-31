#!/bin/bash
# check_setup.sh - Super-Bash Environment Health Check Validator

# --- Colors ---
PASS='\033[0;32m'   # Green
FAIL='\033[0;31m'   # Red
WARN='\033[1;33m'   # Yellow
INFO='\033[0;34m'   # Blue
NC='\033[0m'        # No Color

echo -e "${INFO}╔════════════════════════════════════════════╗${NC}"
echo -e "${INFO}║   Super-Bash Environment Health Check     ║${NC}"
echo -e "${INFO}╚════════════════════════════════════════════╝${NC}\n"

# Counter for results
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

print_install_hint() {
    local tool="$1"

    # detect a package manager (best-effort)
    local pm=""
    if command -v apt >/dev/null 2>&1; then
        pm="apt"
    elif command -v dnf >/dev/null 2>&1; then
        pm="dnf"
    elif command -v yum >/dev/null 2>&1; then
        pm="yum"
    elif command -v pacman >/dev/null 2>&1; then
        pm="pacman"
    fi

    case "$tool" in
        git|curl|make|unzip)
            case "$pm" in
                apt)
                    case "$tool" in
                        make)  echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo apt update && sudo apt install -y make build-essential" ;;
                        unzip) echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo apt update && sudo apt install -y unzip" ;;
                        *)     echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo apt update && sudo apt install -y $tool" ;;
                    esac
                    ;;
                dnf)
                    case "$tool" in
                        make)  echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo dnf install -y make gcc gcc-c++" ;;
                        unzip) echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo dnf install -y unzip" ;;
                        *)     echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo dnf install -y $tool" ;;
                    esac
                    ;;
                yum)
                    case "$tool" in
                        make)  echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo yum install -y make gcc gcc-c++" ;;
                        unzip) echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo yum install -y unzip" ;;
                        *)     echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo yum install -y $tool" ;;
                    esac
                    ;;
                pacman)
                    case "$tool" in
                        make)  echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo pacman -S --needed make base-devel" ;;
                        unzip) echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo pacman -S --needed unzip" ;;
                        *)     echo -e "[ ${INFO}ℹ HINT${NC} ] Install: sudo pacman -S --needed $tool" ;;
                    esac
                    ;;
                *)
                    echo -e "[ ${INFO}ℹ HINT${NC} ] Install '$tool' using your system package manager."
                    ;;
            esac
            ;;
        fzf|zoxide|bun|oh-my-posh)
            echo -e "[ ${INFO}ℹ HINT${NC} ] Run: bash setup.sh (installs $tool for this environment)"
            ;;
        kubectl)
            # kubectl is intentionally not installed by setup.sh (optional)
            case "$pm" in
                apt)
                    echo -e "[ ${INFO}ℹ HINT${NC} ] Install kubectl (options): sudo snap install kubectl --classic  OR  follow https://kubernetes.io/docs/tasks/tools/"
                    ;;
                *)
                    echo -e "[ ${INFO}ℹ HINT${NC} ] Install kubectl: https://kubernetes.io/docs/tasks/tools/"
                    ;;
            esac
            ;;
        oci)
            echo -e "[ ${INFO}ℹ HINT${NC} ] Install OCI CLI: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
            ;;
        *)
            # No hint
            ;;
    esac
}

check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "[ ${PASS}✓ OK${NC} ] $1 is installed"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "[ ${FAIL}✗ FAIL${NC} ] $1 is NOT installed"
        print_install_hint "$1"
        ((FAIL_COUNT++))
        return 1
    fi
}

check_path() {
    local path="$1"
    local description="${2:-$path}"
    if [ -e "$path" ]; then
        echo -e "[ ${PASS}✓ OK${NC} ] $description"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "[ ${WARN}⚠ MISSING${NC} ] $description"
        ((WARN_COUNT++))
        return 1
    fi
}

check_path_fail() {
    local path="$1"
    local description="${2:-$path}"
    if [ -e "$path" ]; then
        echo -e "[ ${PASS}✓ OK${NC} ] $description"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "[ ${FAIL}✗ FAIL${NC} ] $description"
        ((FAIL_COUNT++))
        return 1
    fi
}

# 1. Core Engines
echo -e "${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${INFO}📦 Core Engines${NC}"
echo -e "${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_cmd fzf
check_cmd zoxide

# Bun check - don't fail if not installed, it's installed by setup.sh
if command -v bun >/dev/null 2>&1; then
    check_cmd bun
else
    echo -e "[ ${WARN}⚠ INFO${NC} ] bun not installed (will be installed by setup.sh)"
    ((WARN_COUNT++))
fi

check_path_fail "$HOME/.local/share/blesh/ble.sh" "ble.sh installation"

if [ -d "$HOME/.cache/blesh" ]; then
    echo -e "[ ${PASS}✓ OK${NC} ] ble.sh cache is initialized"
    ((PASS_COUNT++))
else
    echo -e "[ ${WARN}⚠ INFO${NC} ] ble.sh cache not found (will be created on first use)"
    ((WARN_COUNT++))
fi

# 2. Kubernetes & OCI
echo -e "\n${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${INFO}☸️  DevOps Tools${NC}"
echo -e "${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v kubectl >/dev/null 2>&1; then
    echo -e "[ ${PASS}✓ OK${NC} ] kubectl is installed"
    ((PASS_COUNT++))
    # Check KUBECONFIG
    if [ -n "$KUBECONFIG" ] && [ -f "$KUBECONFIG" ]; then
        echo -e "[ ${PASS}✓ OK${NC} ] KUBECONFIG is set and valid: $KUBECONFIG"
        ((PASS_COUNT++))
    elif [ -f "$HOME/.kube/config" ]; then
        echo -e "[ ${WARN}⚠ INFO${NC} ] Using default kubeconfig: $HOME/.kube/config"
        ((WARN_COUNT++))
    else
        echo -e "[ ${WARN}⚠ INFO${NC} ] KUBECONFIG not set and default not found"
        ((WARN_COUNT++))
    fi
else
    echo -e "[ ${WARN}⚠ INFO${NC} ] kubectl not installed (optional)"
    print_install_hint "kubectl"
    ((WARN_COUNT++))
fi

if command -v oci >/dev/null 2>&1; then
    echo -e "[ ${PASS}✓ OK${NC} ] oci is installed"
    ((PASS_COUNT++))
    # Check OCI CLI autocomplete (dynamically find for any Python version)
    oci_path=$(find "$HOME/lib/oracle-cli" -name "oci_autocomplete.sh" 2>/dev/null | head -1)
    if [ -n "$oci_path" ] && [ -f "$oci_path" ]; then
        echo -e "[ ${PASS}✓ OK${NC} ] OCI CLI autocomplete script: $oci_path"
        ((PASS_COUNT++))
    else
        echo -e "[ ${WARN}⚠ INFO${NC} ] OCI CLI autocomplete script not found (optional)"
        ((WARN_COUNT++))
    fi
else
    echo -e "[ ${WARN}⚠ INFO${NC} ] OCI CLI not installed (optional)"
    print_install_hint "oci"
    ((WARN_COUNT++))
fi

# 3. Bun Runtime
echo -e "\n${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${INFO}⚡ Bun Runtime${NC}"
echo -e "${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v bun >/dev/null 2>&1; then
    echo -e "[ ${PASS}✓ OK${NC} ] Bun is installed and in PATH"
    ((PASS_COUNT++))
elif [ -d "$HOME/.bun" ]; then
    echo -e "[ ${WARN}⚠ INFO${NC} ] Bun installed but not in PATH (will be available after sourcing .bashrc)"
    ((WARN_COUNT++))
    if grep -q "BUN_INSTALL" "$HOME/.bashrc" 2>/dev/null; then
        echo -e "[ ${PASS}✓ OK${NC} ] Bun PATH configuration found in .bashrc"
        ((PASS_COUNT++))
    fi
else
    echo -e "[ ${WARN}⚠ INFO${NC} ] Bun not installed (optional - will be installed by setup.sh)"
    ((WARN_COUNT++))
fi

# 4. Prompt & Visuals
echo -e "\n${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${INFO}🎨 Visuals (oh-my-posh)${NC}"
echo -e "${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if check_cmd oh-my-posh; then
    # Check for theme files (prioritize custom dotfiles theme)
    linux_theme="$HOME/dotfiles/jandedobbeleer.omp.json"
    
    if [ -f "$linux_theme" ]; then
        echo -e "[ ${PASS}✓ OK${NC} ] Theme found (custom dotfiles): $linux_theme"
        ((PASS_COUNT++))
    elif [ -n "${WSL_DISTRO_NAME:-}" ] || [ -n "${WSLENV:-}" ]; then
        # Fallback: Try Windows oh-my-posh installation
        WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n' || echo "")
        win_theme="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/oh-my-posh/themes/jandedobbeleer.omp.json"
        if [ -n "$WIN_USER" ] && [ -f "$win_theme" ]; then
            echo -e "[ ${WARN}⚠ INFO${NC} ] Using Windows default theme (custom theme recommended): $win_theme"
            ((WARN_COUNT++))
        else
            echo -e "[ ${WARN}⚠ INFO${NC} ] Theme file not found (using oh-my-posh default)"
            ((WARN_COUNT++))
        fi
    else
        echo -e "[ ${WARN}⚠ INFO${NC} ] Theme file not found (using oh-my-posh default)"
        ((WARN_COUNT++))
    fi
fi

# 5. Functions & Shortcuts
echo -e "\n${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${INFO}🔧 Custom Functions${NC}"
echo -e "${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Important: this script runs in its own non-interactive process, so it cannot
# directly see functions loaded in your *current* terminal session.
# Instead, we validate functions by launching an interactive bash that loads ~/.bashrc.
check_function() {
    local func_name="$1"
    local func_desc="$2"

    # Most accurate: does an interactive shell (which reads ~/.bashrc) have the function?
    if bash -ic "declare -f ${func_name} >/dev/null 2>&1" >/dev/null 2>&1; then
        echo -e "[ ${PASS}✓ OK${NC} ] $func_desc is available in an interactive shell"
        ((PASS_COUNT++))
        return 0
    fi

    # Fallback: at least confirm it's defined in ~/.bashrc (even if interactive shell check failed)
    if [ -f "$HOME/.bashrc" ] && grep -qE "^${func_name}\s*\(\)" "$HOME/.bashrc" 2>/dev/null; then
        echo -e "[ ${WARN}⚠ INFO${NC} ] $func_desc is defined in .bashrc (but not detected in interactive check)"
        ((WARN_COUNT++))
        return 1
    fi

    echo -e "[ ${FAIL}✗ FAIL${NC} ] $func_desc is NOT found in .bashrc"
    ((FAIL_COUNT++))
    return 1
}

check_function "kn" "kn (Context Switcher)"
check_function "ksn" "ksn (Namespace Switcher)"
check_function "klp" "klp (Pod Logs)"
check_function "kxp" "kxp (Pod Exec)"
check_function "kdp" "kdp (Pod Describe)"

# 6. Configuration Files
echo -e "\n${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${INFO}📄 Configuration Files${NC}"
echo -e "${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_path_fail "$HOME/.bashrc" "Main bashrc configuration"

# Theme file check - prioritize custom dotfiles theme
if [ -f "$HOME/dotfiles/jandedobbeleer.omp.json" ]; then
    check_path "$HOME/dotfiles/jandedobbeleer.omp.json" "Oh-my-posh custom theme file (dotfiles)"
else
    echo -e "[ ${WARN}⚠ INFO${NC} ] Custom oh-my-posh theme not in dotfiles (run setup.sh to install)"
    ((WARN_COUNT++))
fi

# Summary
echo -e "\n${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${INFO}📊 Summary${NC}"
echo -e "${INFO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

TOTAL=$((PASS_COUNT + FAIL_COUNT + WARN_COUNT))

echo -e "${PASS}✓ Passed:${NC} $PASS_COUNT"
echo -e "${WARN}⚠ Warnings:${NC} $WARN_COUNT"
echo -e "${FAIL}✗ Failed:${NC} $FAIL_COUNT"
echo -e "${INFO}Total checks:${NC} $TOTAL"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    if [ $WARN_COUNT -gt 0 ]; then
        echo -e "${WARN}✅ Health check PASSED with $WARN_COUNT warning(s).${NC}"
        echo -e "${INFO}💡 Most items are configured correctly. Warnings are typically for items that need terminal restart.${NC}"
        exit 0
    else
        echo -e "${PASS}✅ Health check PASSED! Your Super-Bash environment is fully ready.${NC}"
        exit 0
    fi
else
    echo -e "${WARN}⚠️  Health check completed with $FAIL_COUNT failure(s) and $WARN_COUNT warning(s).${NC}"
    echo -e "${INFO}💡 Tip: Functions marked as 'not loaded' just need: source ~/.bashrc (or restart terminal)${NC}"
    echo -e "${INFO}💡 Tip: Missing items may need to be installed or configured.${NC}"
    exit 1
fi

