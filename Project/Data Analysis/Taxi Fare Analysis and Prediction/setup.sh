#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$PROJECT_DIR/env"
REQ_FILE="$PROJECT_DIR/requirements.txt"
PYTHON_EXE=""

echo "=================================================="
echo "Project setup started"
echo "Project directory: $PROJECT_DIR"
echo "Virtual env path:  $VENV_DIR"
echo "=================================================="

# ------------------------------------------------------------------------------
# Find a usable Python executable
# ------------------------------------------------------------------------------
if command -v python3 &>/dev/null; then
    PYTHON_EXE="python3"
elif command -v python &>/dev/null; then
    PYTHON_EXE="python"
else
    echo "[ERROR] Python was not found on PATH."
    echo "Install Python 3.9+ and ensure 'python3' or 'python' is available."
    exit 1
fi

# Verify it's Python 3
PY_MAJOR=$("$PYTHON_EXE" -c "import sys; print(sys.version_info.major)")
if [[ "$PY_MAJOR" != "3" ]]; then
    echo "[ERROR] Found Python but it is version $PY_MAJOR. Python 3.9+ is required."
    exit 1
fi

# ------------------------------------------------------------------------------
# Create virtual environment if it does not exist
# ------------------------------------------------------------------------------
if [[ -f "$VENV_DIR/bin/python" ]]; then
    echo "[INFO] Existing virtual environment detected. Reusing: $VENV_DIR"
else
    echo "[INFO] Creating virtual environment..."
    "$PYTHON_EXE" -m venv "$VENV_DIR"
fi

# ------------------------------------------------------------------------------
# Upgrade pip/setuptools/wheel inside the venv
# ------------------------------------------------------------------------------
echo "[INFO] Upgrading pip, setuptools, wheel..."
"$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel

# ------------------------------------------------------------------------------
# Install dependencies if requirements.txt exists
# ------------------------------------------------------------------------------
if [[ -f "$REQ_FILE" ]]; then
    echo "[INFO] Installing dependencies from requirements.txt..."
    "$VENV_DIR/bin/python" -m pip install -r "$REQ_FILE"
else
    echo "[WARN] No requirements.txt found at $REQ_FILE. Skipping dependency install."
fi

# ------------------------------------------------------------------------------
# Smoke check
# ------------------------------------------------------------------------------
echo "[INFO] Verifying Python in virtual environment..."
"$VENV_DIR/bin/python" --version

echo ""
echo "[SUCCESS] Setup complete."
echo "To activate the virtual environment, run:"
echo "  source \"$VENV_DIR/bin/activate\""
echo ""
