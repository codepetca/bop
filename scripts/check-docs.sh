#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail=0

DOC_PATHS=(
    "AGENTS.md"
    "README.md"
    "CLAUDE.md"
    "WARP.md"
    "architecture.md"
    "docs"
    ".ai/START-HERE.md"
    ".ai/features.json"
    "scripts/verify-env.sh"
    ".github"
)

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

run_search() {
    local label="$1"
    local pattern="$2"

    if command -v rg >/dev/null 2>&1; then
        if rg -n --hidden --glob '!.git/' -S "$pattern" "${DOC_PATHS[@]}" >/dev/null; then
            print_header "❌ $label"
            rg -n --hidden --glob '!.git/' -S "$pattern" "${DOC_PATHS[@]}"
            fail=1
        fi
    else
        if grep -RInE --exclude-dir .git "$pattern" "${DOC_PATHS[@]}" >/dev/null 2>&1; then
            print_header "❌ $label"
            grep -RInE --exclude-dir .git "$pattern" "${DOC_PATHS[@]}"
            fail=1
        fi
    fi
}

run_search "Found references to removed TODO.md (use .ai/features.json instead)" "TODO\\.md"
run_search "Found outdated 1.4s start-time references (start is ~3s)" "\\b1\\.4\\b|1\\.4s|1\\.4 seconds"
run_search "Found references to removed feature scripts (use scripts/features.sh)" "features-view\\.sh|feature-pass\\.sh|feature-fail\\.sh"
run_search "Found jq install instructions (jq is no longer required)" "brew install jq"

if [ "$fail" -ne 0 ]; then
    echo ""
    echo "Fix the matches above to reduce documentation drift."
    exit 1
fi

echo "✅ Docs consistency checks passed"
