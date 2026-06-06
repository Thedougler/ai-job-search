#!/usr/bin/env bash
set -euo pipefail

# AI Job Search — dependency installer
# Supports macOS (Homebrew) and Debian/Ubuntu Linux.

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

info()    { echo -e "${BOLD}==> $*${RESET}"; }
success() { echo -e "${GREEN}✓  $*${RESET}"; }
warn()    { echo -e "${YELLOW}!  $*${RESET}"; }

OS="$(uname -s)"

# ── 1. Claude Code ────────────────────────────────────────────────────────────
info "Checking Claude Code..."
if command -v claude &>/dev/null; then
  success "Claude Code already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
  info "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
  success "Claude Code installed"
fi

# ── 2. Bun ────────────────────────────────────────────────────────────────────
info "Checking Bun..."
if command -v bun &>/dev/null; then
  success "Bun already installed ($(bun --version))"
else
  info "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  # Make bun available in current session
  export BUN_INSTALL="${HOME}/.bun"
  export PATH="${BUN_INSTALL}/bin:${PATH}"
  success "Bun installed — restart your shell or run: source ~/.bashrc / source ~/.zshrc"
fi

# ── 3. Python 3 ───────────────────────────────────────────────────────────────
info "Checking Python 3..."
if command -v python3 &>/dev/null; then
  PY_VERSION="$(python3 --version)"
  success "Python already installed ($PY_VERSION)"
else
  if [[ "$OS" == "Darwin" ]]; then
    warn "Python not found. Install via: brew install python"
  else
    warn "Python not found. Install via: sudo apt install python3"
  fi
fi

# ── 4. openpyxl (optional — only needed for salary Excel import) ──────────────
info "Checking openpyxl (optional, for salary Excel import)..."
if python3 -c "import openpyxl" &>/dev/null 2>&1; then
  success "openpyxl already installed"
else
  info "Installing openpyxl..."
  pip3 install --quiet openpyxl
  success "openpyxl installed"
fi

# ── 5. LaTeX ─────────────────────────────────────────────────────────────────
info "Checking LaTeX (lualatex + xelatex)..."
if command -v lualatex &>/dev/null && command -v xelatex &>/dev/null; then
  success "LaTeX already installed"
else
  info "Installing LaTeX..."
  if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
      warn "Homebrew not found. Install it first: https://brew.sh"
      warn "Then re-run this script."
      exit 1
    fi
    brew install --cask mactex-no-gui
    # Reload PATH so lualatex/xelatex are available immediately
    eval "$(/usr/libexec/path_helper)"
    success "MacTeX installed — if lualatex/xelatex aren't found, run: eval \"\$(/usr/libexec/path_helper)\""
  elif [[ "$OS" == "Linux" ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y texlive-full
    success "TeX Live installed"
  else
    warn "Unsupported OS: $OS. Install LaTeX manually: https://tug.org/mactex/"
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}All dependencies installed.${RESET}"
echo ""
echo "Next steps:"
echo "  1. Start Claude Code in this directory:  claude"
echo "  2. Run the setup interview:              /setup"
echo ""
echo "See SETUP.md for full onboarding instructions."
