$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter was not found on PATH."
}

flutter doctor -v
flutter create . --platforms=android,ios,web,windows,macos,linux
flutter pub get

Write-Host "QuizForge bootstrap complete."
