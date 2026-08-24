#!/usr/bin/env bash
set -euo pipefail

python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/test_check_release_metadata.py
python3 tool/test_prepare_web_assets.py
python3 tool/test_generate_platform_branding.py
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
python3 tool/check_release_metadata.py
flutter pub get --enforce-lockfile
git diff --exit-code -- pubspec.lock analysis_options.yaml
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
