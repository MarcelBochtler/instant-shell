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

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================================
# Global Variables
# ============================================================================

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TMP_DIR="/tmp/remote-cli-${TIMESTAMP}"

# ============================================================================
# Installation Functions
# ============================================================================

install_fish() {
    print_info "Installing Fish shell..."

    mkdir -p "${TMP_DIR}/bin"

    # Get latest version from GitHub API
    LATEST_VERSION=$(curl -s https://api.github.com/repos/fish-shell/fish-shell/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    print_info "Latest version: ${LATEST_VERSION}"

    # Download and extract
    print_info "Downloading and extracting..."
    curl -sL "https://github.com/fish-shell/fish-shell/releases/download/${LATEST_VERSION}/fish-${LATEST_VERSION}-linux-x86_64.tar.xz" | tar xJf - -C "${TMP_DIR}/bin"

    print_success "Fish shell installed successfully"
}

# ============================================================================
# Main
# ============================================================================

main() {
    install_fish

    # Start fish with the bin directory in PATH
    print_info "Starting Fish shell..."
    PATH="${TMP_DIR}/bin:${PATH}" "${TMP_DIR}/bin/fish" -C "set -g fish_greeting"
}

main "$@"
