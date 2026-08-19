#!/usr/bin/env python3
"""Validate QuizForge package/changelog/application release metadata without Flutter."""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from datetime import date
from pathlib import Path

SEMVER_COMPONENT = r"(?:0|[1-9]\d*)"
PUBSPEC_VERSION_RE = re.compile(
    rf"^version:\s*(?P<major>{SEMVER_COMPONENT})\."
    rf"(?P<minor>{SEMVER_COMPONENT})\."
    rf"(?P<patch>{SEMVER_COMPONENT})\+"
    r"(?P<build>[1-9]\d*)\s*$",
    re.MULTILINE,
)
CHANGELOG_RELEASE_RE = re.compile(
    rf"^## \[(?P<version>{SEMVER_COMPONENT}\."
    rf"{SEMVER_COMPONENT}\.{SEMVER_COMPONENT})\] - "
    r"(?P<date>\d{4}-\d{2}-\d{2})\s*$",
    re.MULTILINE,
)
APP_VERSION_RE = re.compile(
    r"^\s*static const String version\s*=\s*"
    rf"(?P<quote>['\"])(?P<version>{SEMVER_COMPONENT}\."
    rf"{SEMVER_COMPONENT}\.{SEMVER_COMPONENT})(?P=quote);\s*$",
    re.MULTILINE,
)


@dataclass(frozen=True, order=True)
class SemVer:
    major: int
    minor: int
    patch: int

    @property
    def public(self) -> str:
        return f"{self.major}.{self.minor}.{self.patch}"


def _read(path: Path, errors: list[str]) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as error:
        errors.append(f"Cannot read {path.as_posix()}: {error.__class__.__name__}.")
        return ""


def validate_release_metadata(root: Path) -> list[str]:
    """Return deterministic release-metadata validation errors for *root*."""

    errors: list[str] = []
    pubspec = _read(root / "pubspec.yaml", errors)
    changelog = _read(root / "CHANGELOG.md", errors)
    versioning = _read(root / "docs" / "versioning.md", errors)
    app_constants = _read(root / "lib" / "src" / "core" / "app_constants.dart", errors)
    if errors:
        return errors

    version_matches = list(PUBSPEC_VERSION_RE.finditer(pubspec))
    if len(version_matches) != 1:
        errors.append(
            "pubspec.yaml must contain exactly one MAJOR.MINOR.PATCH+BUILD version "
            "with non-negative SemVer components and a positive build number."
        )
        return errors

    match = version_matches[0]
    current = SemVer(
        int(match.group("major")),
        int(match.group("minor")),
        int(match.group("patch")),
    )
    build = int(match.group("build"))

    app_version_matches = list(APP_VERSION_RE.finditer(app_constants))
    if len(app_version_matches) != 1:
        errors.append(
            "lib/src/core/app_constants.dart must contain exactly one semantic "
            "AppConstants.version constant without leading-zero components."
        )
    elif app_version_matches[0].group("version") != current.public:
        errors.append(
            "AppConstants.version must match the public pubspec.yaml version "
            f"{current.public}."
        )

    if "## [Unreleased]" not in changelog:
        errors.append("CHANGELOG.md must contain an Unreleased section.")

    releases: list[tuple[SemVer, date]] = []
    seen: set[SemVer] = set()
    for release_match in CHANGELOG_RELEASE_RE.finditer(changelog):
        version_text = release_match.group("version")
        version = SemVer(*(int(part) for part in version_text.split(".")))
        release_date_text = release_match.group("date")
        try:
            release_date = date.fromisoformat(release_date_text)
        except ValueError:
            errors.append(
                f"CHANGELOG.md release {version.public} has invalid date "
                f"{release_date_text}."
            )
            continue
        if version in seen:
            errors.append(f"CHANGELOG.md contains duplicate release {version.public}.")
        else:
            seen.add(version)
        releases.append((version, release_date))

    if current not in seen:
        errors.append(
            f"CHANGELOG.md must contain a dated [{current.public}] release entry "
            "matching pubspec.yaml."
        )

    release_versions = [version for version, _ in releases]
    if release_versions and release_versions != sorted(release_versions, reverse=True):
        errors.append("CHANGELOG.md release entries must be ordered newest version first.")

    if current.major >= 1 and "## Pre-1.0 policy" in versioning:
        errors.append(
            "docs/versioning.md still declares a pre-1.0 policy for a stable major version."
        )

    declared_build = f"{current.public}+{build}"
    if declared_build not in versioning:
        errors.append(
            "docs/versioning.md must state the maintained package version "
            f"{declared_build}."
        )
    if f"v{current.public}" not in versioning:
        errors.append(
            "docs/versioning.md must include the matching public release tag "
            f"v{current.public}."
        )

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Validate QuizForge package, in-app version, changelog, and versioning metadata."
        )
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Repository root (defaults to the parent of tool/).",
    )
    args = parser.parse_args()

    errors = validate_release_metadata(args.root.resolve())
    if errors:
        for error in errors:
            print(f"release-metadata error: {error}")
        return 1

    print("Release metadata is consistent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
