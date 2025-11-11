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

safe_wget() {
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 --tries=3 "$@"
}

download_and_extract() {
    local repo=$1 # GitHub repository in the format "owner/repo"
    local filename=$2 # Filename with placeholders {VERSION} or {VERSION_NO_V}
    local toolname=$3 # Name of the tool to download
    local strip=${4:-1} # The level to strip from the archive (default: 1)

    mkdir -p "${TMP_DIR}/${toolname}"

    local version=$(safe_wget -qO- https://api.github.com/repos/${repo}/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    local version_no_v="${version#v}"

    # Replace placeholders in filename
    filename="${filename//\{VERSION\}/$version}"
    filename="${filename//\{VERSION_NO_V\}/$version_no_v}"

    local url="https://github.com/${repo}/releases/download/${version}/${filename}"

    if [[ "$filename" == *.zip ]]; then
        # Handle zip files
        local temp_file="${TMP_DIR}/${toolname}.zip"
        safe_wget -O "$temp_file" "$url"

        local extract_dir="${TMP_DIR}/${toolname}_extract"
        mkdir -p "$extract_dir"
        unzip -q "$temp_file" -d "$extract_dir"

        if [ $strip -eq 1 ]; then
            mv "$extract_dir"/*/* "${TMP_DIR}/${toolname}/"
        else
            mv "$extract_dir"/* "${TMP_DIR}/${toolname}/"
        fi

        rm -rf "$extract_dir" "$temp_file"
    elif [[ "$filename" == *.tar.xz ]]; then
        safe_wget -qO- "$url" | tar xJf - -C "${TMP_DIR}/${toolname}" --strip-components=${strip}
    elif [[ "$filename" == *.tar.gz ]]; then
        safe_wget -qO- "$url" | tar xzf - -C "${TMP_DIR}/${toolname}" --strip-components=${strip}
    elif [[ "$filename" != *.* ]]; then
        # Handle binary files (no extension)
        safe_wget -O "${TMP_DIR}/${toolname}/${toolname}" "$url"
        chmod +x "${TMP_DIR}/${toolname}/${toolname}"
    else
        print_error "Unsupported file format: ${filename}"
        exit 1
    fi
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

install_yazi() {
    download_and_extract "sxyazi/yazi" "yazi-x86_64-unknown-linux-musl.zip" "yazi"
    TOOLS_PATH="${TMP_DIR}/yazi:${TOOLS_PATH}"
    print_status "Yazi installed."
}

install_zoxide() {
    download_and_extract "ajeetdsouza/zoxide" "zoxide-{VERSION_NO_V}-x86_64-unknown-linux-musl.tar.gz" "zoxide" 0
    TOOLS_PATH="${TMP_DIR}/zoxide:${TOOLS_PATH}"
    print_status "zoxide installed."
}

install_jq() {
    download_and_extract "jqlang/jq" "jq-linux-amd64" "jq"
    TOOLS_PATH="${TMP_DIR}/jq:${TOOLS_PATH}"
    print_status "jq installed."
}

install_yq() {
    download_and_extract "mikefarah/yq" "yq_linux_amd64" "yq"
    TOOLS_PATH="${TMP_DIR}/yq:${TOOLS_PATH}"
    print_status "yq installed."
}

fetch_fish_config() {
    safe_wget -O "${TMP_DIR}/config.fish" "https://raw.githubusercontent.com/MarcelBochtler/instant-shell/refs/heads/main/config.fish"
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
    install_yazi
    install_zoxide
    install_jq
    install_yq

    print_success "Setup complete."

    PATH="${TOOLS_PATH}${PATH}" exec "${TMP_DIR}/fish/fish" -C "source ${TMP_DIR}/config.fish"
}

main "$@"
