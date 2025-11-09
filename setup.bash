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

# ============================================================================
# Global Variables
# ============================================================================

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TMP_DIR="/tmp/instant-shell-${TIMESTAMP}"

# ============================================================================
# Installation Functions
# ============================================================================

install_fish() {
    mkdir -p "${TMP_DIR}/bin"
    LATEST_VERSION=$(curl -s https://api.github.com/repos/fish-shell/fish-shell/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -sL "https://github.com/fish-shell/fish-shell/releases/download/${LATEST_VERSION}/fish-${LATEST_VERSION}-linux-x86_64.tar.xz" | tar xJf - -C "${TMP_DIR}/bin"

    print_status "Fish shell version ${LATEST_VERSION} installed."
}

install_micro() {
    mkdir -p "${TMP_DIR}/bin"
    LATEST_VERSION=$(curl -s https://api.github.com/repos/zyedidia/micro/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    curl -sL "https://github.com/zyedidia/micro/releases/download/v${LATEST_VERSION}/micro-${LATEST_VERSION}-linux64-static.tar.gz" | tar xzf - -C "${TMP_DIR}/bin" --strip-components=1

    print_status "Micro editor version ${LATEST_VERSION} installed."
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

    print_success "Setup complete."

    PATH="${TMP_DIR}/bin:${PATH}" exec "${TMP_DIR}/bin/fish" -C "source ${TMP_DIR}/config.fish"
}

main "$@"
