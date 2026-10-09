#!/usr/bin/env bash
# ============================================================
# pre_commit.sh - flare_flutter_sdk quality gate (macOS/Linux)
# Run before every commit: ./scripts/pre_commit.sh
# ============================================================

set -uo pipefail

# Always run from the repository root, wherever the script is called from.
cd "$(dirname "$0")/.." || exit 1

# ---- Colors ----
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo ""
echo -e "${CYAN}==========================================${RESET}"
echo -e "${CYAN}  flare_flutter_sdk pre-commit check${RESET}"
echo -e "${CYAN}==========================================${RESET}"

# ---- Section 1: Format ----
echo ""
echo -e "${YELLOW}[1/3] dart format --set-exit-if-changed .${RESET}"
if ! dart format --set-exit-if-changed .; then
  echo -e "${RED}FAILED: Format issues found. Run 'dart format .' to fix.${RESET}"
  exit 1
fi
echo -e "${GREEN}Format: OK${RESET}"

# ---- Section 2: Analyze ----
echo ""
echo -e "${YELLOW}[2/3] dart analyze --fatal-infos${RESET}"
if ! dart analyze --fatal-infos; then
  echo -e "${RED}FAILED: Analysis errors found.${RESET}"
  exit 1
fi
echo -e "${GREEN}Analyze: OK${RESET}"

# ---- Section 3: Test ----
echo ""
echo -e "${YELLOW}[3/3] flutter test${RESET}"
if ! flutter test; then
  echo -e "${RED}FAILED: Tests failed.${RESET}"
  exit 1
fi
echo -e "${GREEN}Tests: OK${RESET}"

# ---- Done ----
echo ""
echo -e "${GREEN}==========================================${RESET}"
echo -e "${GREEN}  All checks passed. Ready to commit.${RESET}"
echo -e "${GREEN}==========================================${RESET}"
