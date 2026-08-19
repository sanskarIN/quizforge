#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter was not found on PATH." >&2
  exit 1
fi

flutter doctor -v
flutter create . --platforms=android,ios,web,windows,macos,linux
flutter pub get

echo "QuizForge bootstrap complete."
