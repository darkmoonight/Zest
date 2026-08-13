#!/usr/bin/env bash
# Verifies i18n key parity across locales (missing/extra keys).
# Run after editing assets/i18n/*.i18n.json.
#
# Note: `dart run slang analyze --full` currently fails on numeric keys
# "12" / "24" (timeformat labels). Use plain `slang analyze` instead.
set -euo pipefail

cd "$(dirname "$0")/.."

dart run slang analyze
