#!/usr/bin/env bash

set -euo pipefail

# Find repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=== ArcKit Antigravity Installer ==="
echo "Repository Root: ${REPO_ROOT}"

# Directories
GEMINI_DIR="${HOME}/.gemini"
CLI_PLUGINS_DIR="${GEMINI_DIR}/config/plugins"
CLI_SKILLS_DIR="${GEMINI_DIR}/config/skills"
IDE_PLUGINS_DIR="${GEMINI_DIR}/antigravity-ide/plugins"
IDE_SKILLS_DIR="${GEMINI_DIR}/antigravity-ide/skills"

SKILLS=(
    "architecture-workflow"
    "mermaid-syntax"
    "plantuml-syntax"
    "wardley-mapping"
)

# 1. Install Plugin for CLI
if [ -d "${GEMINI_DIR}/config" ]; then
    echo "Configuring Antigravity CLI plugin..."
    mkdir -p "${CLI_PLUGINS_DIR}"
    rm -rf "${CLI_PLUGINS_DIR}/arckit"
    ln -s "${REPO_ROOT}" "${CLI_PLUGINS_DIR}/arckit"
    echo "  Symlinked plugin to CLI plugins folder."

    # Skills symlinks
    mkdir -p "${CLI_SKILLS_DIR}"
    for skill in "${SKILLS[@]}"; do
        rm -rf "${CLI_SKILLS_DIR}/${skill}"
        ln -s "${REPO_ROOT}/skills/${skill}" "${CLI_SKILLS_DIR}/${skill}"
        echo "  Symlinked skill '${skill}' to CLI skills folder."
    done
fi

# 2. Install Plugin for IDE
if [ -d "${GEMINI_DIR}/antigravity-ide" ]; then
    echo "Configuring Antigravity IDE plugin..."
    mkdir -p "${IDE_PLUGINS_DIR}"
    rm -rf "${IDE_PLUGINS_DIR}/arckit"
    ln -s "${REPO_ROOT}" "${IDE_PLUGINS_DIR}/arckit"
    echo "  Symlinked plugin to IDE plugins folder."

    # Skills symlinks
    mkdir -p "${IDE_SKILLS_DIR}"
    for skill in "${SKILLS[@]}"; do
        rm -rf "${IDE_SKILLS_DIR}/${skill}"
        ln -s "${REPO_ROOT}/skills/${skill}" "${IDE_SKILLS_DIR}/${skill}"
        echo "  Symlinked skill '${skill}' to IDE skills folder."
    done
fi

# 3. Enable Extension
ENABLEMENT_FILE="${GEMINI_DIR}/extensions/extension-enablement.json"
if [ -f "${ENABLEMENT_FILE}" ]; then
    echo "Checking extension enablement..."
    # Ensure arckit is added to extension-enablement.json if not present
    if ! grep -q '"arckit"' "${ENABLEMENT_FILE}"; then
        echo "  Enabling 'arckit' in extension-enablement.json..."
        # Add entry using python to safely edit JSON
        python3 -c "
import json
with open('${ENABLEMENT_FILE}', 'r') as f:
    data = json.load(f)
if 'arckit' not in data:
    data['arckit'] = {'overrides': ['${HOME}/*']}
    with open('${ENABLEMENT_FILE}', 'w') as f:
        json.dump(data, f, indent=2)
"
    fi
fi

echo "ArcKit successfully installed for both Antigravity CLI and Antigravity IDE!"
echo "===================================="
