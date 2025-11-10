#!/bin/bash

set -e

# ============================================================================
# Colors
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

print_status() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

download_and_extract() {
    local repo=$1
    local filename=$2
    local toolname=$3
    local strip=${4:-1}

    mkdir -p "${TMP_DIR}/${toolname}"

    local version=$(curl -s https://api.github.com/repos/${repo}/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    local version_no_v="${version#v}"

    # Replace placeholders in filename
    filename="${filename//\{VERSION\}/$version}"
    filename="${filename//\{VERSION_NO_V\}/$version_no_v}"

    local url="https://github.com/${repo}/releases/download/${version}/${filename}"

    local tar_flags
    if [[ "$filename" == *.tar.xz ]]; then
        tar_flags="xJf"
    elif [[ "$filename" == *.tar.gz ]]; then
        tar_flags="xzf"
    fi

    curl -sL "$url" | tar $tar_flags - -C "${TMP_DIR}/${toolname}" --strip-components=${strip}
}

# ============================================================================
# Global Variables
# ============================================================================

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TMP_DIR="/tmp/instant-shell-${TIMESTAMP}"
TOOLS_PATH=""

# ============================================================================
# Installation Functions
# ============================================================================

install_fish() {
    download_and_extract "fish-shell/fish-shell" "fish-{VERSION}-linux-x86_64.tar.xz" "fish" 0
    TOOLS_PATH="${TMP_DIR}/fish:${TOOLS_PATH}"
    print_status "Fish shell installed."
}

install_micro() {
    download_and_extract "zyedidia/micro" "micro-{VERSION_NO_V}-linux64-static.tar.gz" "micro"
    TOOLS_PATH="${TMP_DIR}/micro:${TOOLS_PATH}"
    print_status "Micro editor installed."
}

install_fd() {
    download_and_extract "sharkdp/fd" "fd-{VERSION}-x86_64-unknown-linux-musl.tar.gz" "fd"
    TOOLS_PATH="${TMP_DIR}/fd:${TOOLS_PATH}"
    print_status "fd installed."
}

install_ripgrep() {
    download_and_extract "BurntSushi/ripgrep" "ripgrep-{VERSION_NO_V}-x86_64-unknown-linux-musl.tar.gz" "ripgrep"
    TOOLS_PATH="${TMP_DIR}/ripgrep:${TOOLS_PATH}"
    print_status "ripgrep installed."
}

fetch_fish_config() {
    curl -sL "https://raw.githubusercontent.com/MarcelBochtler/instant-shell/refs/heads/main/config.fish" -o "${TMP_DIR}/config.fish"
}

# ============================================================================
# Main
# ============================================================================

main() {
    install_fish
    fetch_fish_config

    install_micro
    install_fd
    install_ripgrep

    print_success "Setup complete."

    PATH="${TOOLS_PATH}${PATH}" exec "${TMP_DIR}/fish/fish" -C "source ${TMP_DIR}/config.fish"
}

main "$@"
