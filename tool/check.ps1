$ErrorActionPreference = "Stop"

python tool/test_check_markdown_links.py
python tool/test_check_arb_catalogs.py
python tool/test_check_release_metadata.py
python tool/test_prepare_web_assets.py
python tool/test_generate_platform_branding.py
python tool/test_check_platform_runner_contract.py
python tool/check_markdown_links.py
python tool/check_arb_catalogs.py
python tool/check_release_metadata.py
python tool/check_platform_runner_contract.py
flutter pub get --enforce-lockfile
git diff --exit-code -- pubspec.lock analysis_options.yaml
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
