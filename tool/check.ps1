$ErrorActionPreference = "Stop"

python tool/test_check_markdown_links.py
python tool/test_check_arb_catalogs.py
python tool/check_markdown_links.py
python tool/check_arb_catalogs.py
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
