#---------------------------------------------------------------------------------------------------------------------------------------
#   1. CORE ENVIRONMENT SETTINGS
#---------------------------------------------------------------------------------------------------------------------------------------

# Default editor
export EDITOR="nano"

# Bump the maximum number of file descriptors
ulimit -n 10240

# Parallel native builds for Node
export JOBS=max

# Shared default directories
export DEV_DIR="${DEV_DIR:-$HOME/dev}"

#---------------------------------------------------------------------------------------------------------------------------------------
#   2. PATH CONFIGURATIONS
#---------------------------------------------------------------------------------------------------------------------------------------

# Helper to safely prepend to PATH
add_to_path() {
  [[ -d "$1" ]] || return
  case ":$PATH:" in
  *":$1:"*) ;; # already in PATH
  *) PATH="$1:$PATH" ;;
  esac
}

# Set Homebrew prefix for convenience
export BREW="/opt/homebrew" # brew --prefix

# Core paths (single source of truth — do not add PATH entries in zshrc)
add_to_path "$BREW/bin"
add_to_path "$BREW/sbin"
add_to_path "$HOME/bin"
add_to_path "$HOME/.local/bin" # NemoClaw / local CLI tools
add_to_path "$HOME/.docker/bin" # Docker Desktop CLI
add_to_path "$HOME/.hutch/bin" # Hutch CLI
add_to_path "$HOME/.unity/bin" # Unity CLI

# Project-local binaries are resolved by package-manager scripts. Do not add
# a relative path here: it would let the current directory shadow trusted tools.

# Bun runtime and all former `bun add -g` CLIs come from mise; no ~/.bun/bin
# (or $HOME/Library/pnpm/bin) PATH entry — global installs are not allowed.

# Python is managed by mise; uv is the package manager. No brew Python path.

# Ruby — orphaned (only eza replaced colorls); kept for legacy gems
add_to_path "$BREW/opt/ruby/bin"

#---------------------------------------------------------------------------------------------------------------------------------------
#   4. MOBILE DEVELOPMENT
#---------------------------------------------------------------------------------------------------------------------------------------

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
add_to_path "$ANDROID_HOME/emulator"
add_to_path "$ANDROID_HOME/platform-tools"
add_to_path "$ANDROID_HOME/cmdline-tools/latest/bin"

# Flutter
add_to_path "$DEV_DIR/flutter/bin"

#---------------------------------------------------------------------------------------------------------------------------------------
#   5. OTHER TOOLS & FRAMEWORKS
#---------------------------------------------------------------------------------------------------------------------------------------

# Algorand node
export ALGORAND_DATA="$HOME/node/data"
alias goal="$HOME/node/goal"

# Ruby gem bin dirs (brew rubies, globbed so version upgrades don't break PATH).
# Spawning `ruby` here cost ~0.5s per shell (much more under system load).
for _gem_bin in "$BREW"/lib/ruby/gems/*/bin; do
  [[ -d "$_gem_bin" ]] && add_to_path "$_gem_bin"
done
unset _gem_bin

# LM Studio CLI
add_to_path "$HOME/.lmstudio/bin"

# MTPLX terminal command
add_to_path "$HOME/.mtplx/bin"

# TensorFlow (ML Framework) - hide log warnings
export TF_CPP_MIN_LOG_LEVEL=3

# sccache local disk cache cap for the Rust workspace (default is 5G)
export SCCACHE_CACHE_SIZE="10G"

#---------------------------------------------------------------------------------------------------------------------------------------
#   6. SYSTEM UTILS & PACKAGE MANAGERS
#---------------------------------------------------------------------------------------------------------------------------------------

# Import Homebrew's non-PATH environment only. Its bin/sbin dirs are already
# added via add_to_path above; brew shellenv must not prepend them again.
eval "$($BREW/bin/brew shellenv | command grep -v '^export PATH')"

#---------------------------------------------------------------------------------------------------------------------------------------
#   MISE — single source of truth for dev runtimes AND dev CLIs.
#   Runtimes: Java, Node, Python, Bun. CLIs: act, actionlint, cargo-nextest,
#   circleci, gh, gitleaks, glab, osv-scanner, pipx, ruff, sccache, shellcheck,
#   solidity (solc), supabase, uv, zizmor, plus npm-backed CLIs (pi, graph, kilo,
#   monid, codex, opencode, railway, cf, portless, tsx, turbo, pi-acp).
#   Pins live in the repo's mise/config.toml, symlinked from
#   ~/.config/mise/config.toml. Homebrew owns system packages; never install
#   dev CLIs globally with npm/bun/pipx/cargo — use `mise use -g <tool>`.
#   Activated LAST so mise tool dirs stay FIRST in PATH.
#---------------------------------------------------------------------------------------------------------------------------------------
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
  hash -r  # rehash after PATH changes so shims shadow local tools
fi
