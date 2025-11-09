# Fish Shell Remote CLI Installer

A simple script to download and run the latest Fish shell in an isolated temporary environment.

## Quick Installation

Install and run with a single command:

```bash
curl -fsSL https://gist.githubusercontent.com/USERNAME/GIST_ID/raw/setup.bash | bash
```

**Note:** Replace `USERNAME/GIST_ID` with your actual gist information after uploading.

## What It Does

The installation script will:

1. Create a timestamped directory: `/tmp/cli-marcel-YYYYMMDD-HHMMSS/`
2. Download the latest Fish shell release from GitHub
3. Extract binaries to the `bin/` subdirectory
4. Launch Fish with the bin directory in PATH

## Manual Installation

If you prefer to run the script manually:

```bash
git clone <this-repo-url>
cd remote-cli
./setup.bash
```

## Requirements

- `curl` - for downloading
- `tar` - for extracting
- `bash` - for running the script
