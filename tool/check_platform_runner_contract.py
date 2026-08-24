#!/usr/bin/env python3
"""Validate QuizForge generated-runner identity and dependency-safety contracts."""

from __future__ import annotations

import argparse
from pathlib import Path

CANONICAL_ORG = "io.github.sanskarin"
DEPENDENCY_METADATA = ("pubspec.yaml", "pubspec.lock", "analysis_options.yaml")
WORKFLOW_PATHS = (
    Path(".github/workflows/build.yml"),
    Path(".github/workflows/platform-builds.yml"),
    Path(".github/workflows/release.yml"),
)


def _read(path: Path, errors: list[str]) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as error:
        errors.append(f"Cannot read {path.as_posix()}: {error.__class__.__name__}.")
        return ""


def validate_platform_runner_contract(root: Path) -> list[str]:
    """Return deterministic generated-runner contract errors for *root*."""

    errors: list[str] = []
    expected_restore = (
        "git restore --source=HEAD -- " + " ".join(DEPENDENCY_METADATA)
    )

    for relative_path in WORKFLOW_PATHS:
        path = root / relative_path
        text = _read(path, errors)
        if not text:
            continue

        if "com.example" in text:
            errors.append(
                f"{relative_path.as_posix()} must not use Flutter's com.example "
                "application identity."
            )

        lines = text.splitlines()
        create_indexes = [
            index
            for index, line in enumerate(lines)
            if "flutter create ." in line and "--platforms=" in line
        ]
        if not create_indexes:
            errors.append(
                f"{relative_path.as_posix()} must materialize at least one Flutter "
                "platform runner."
            )
            continue

        for index in create_indexes:
            command = lines[index].strip()
            if f"--org {CANONICAL_ORG}" not in command:
                errors.append(
                    f"{relative_path.as_posix()} runner command must use canonical "
                    f"organization {CANONICAL_ORG}: {command}"
                )
            if "--no-pub" not in command:
                errors.append(
                    f"{relative_path.as_posix()} runner command must use --no-pub: "
                    f"{command}"
                )

            restore_window = "\n".join(lines[index + 1 : index + 4])
            if expected_restore not in restore_window:
                errors.append(
                    f"{relative_path.as_posix()} runner command must restore reviewed "
                    "dependency metadata immediately after scaffolding."
                )

        if "flutter pub get --enforce-lockfile" not in text:
            errors.append(
                f"{relative_path.as_posix()} must enforce the committed application "
                "lockfile."
            )

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate QuizForge generated platform runner workflows."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path.cwd(),
        help="Repository root (defaults to the current working directory).",
    )
    args = parser.parse_args()

    errors = validate_platform_runner_contract(args.root.resolve())
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1

    print("Platform runner contract is consistent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
