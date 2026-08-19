#!/usr/bin/env bash
set -euo pipefail

flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
python3 tool/check_markdown_links.py
flutter analyze
flutter test --coverage
