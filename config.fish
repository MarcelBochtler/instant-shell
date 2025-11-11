# Fish shell configuration for instant-shell

# Disable the fish greeting message
set -g fish_greeting

# Initialize zoxide (use 'z' command instead of overriding 'cd')
zoxide init fish --cmd z | source

# Git aliases
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gph='git push'
alias gd='git diff'

# Directory listing aliases
alias ll='ls -lah'

# File manager alias
alias y='yazi'
