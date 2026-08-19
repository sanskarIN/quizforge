#!/usr/bin/env sh
set -eu

PYTHON_BIN="${PYTHON_BIN:-python3}"

"$PYTHON_BIN" tool/test_check_markdown_links.py
"$PYTHON_BIN" tool/test_check_arb_catalogs.py
"$PYTHON_BIN" tool/check_markdown_links.py .
"$PYTHON_BIN" tool/check_arb_catalogs.py .
