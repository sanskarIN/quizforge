#!/usr/bin/env python3
"""Regression tests for check_release_metadata.py."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from check_release_metadata import validate_release_metadata


class ReleaseMetadataValidatorTest(unittest.TestCase):
    def _write_repo(
        self,
        root: Path,
        *,
        pubspec_version: str = "2.7.4+1",
        app_version: str = "2.7.4",
        changelog: str | None = None,
        versioning: str | None = None,
    ) -> None:
        (root / "docs").mkdir(parents=True, exist_ok=True)
        (root / "lib" / "src" / "core").mkdir(parents=True, exist_ok=True)
        (root / "pubspec.yaml").write_text(
            f"name: quizforge\nversion: {pubspec_version}\n",
            encoding="utf-8",
        )
        (root / "lib" / "src" / "core" / "app_constants.dart").write_text(
            "abstract final class AppConstants {\n"
            f"  static const String version = '{app_version}';\n"
            "}\n",
            encoding="utf-8",
        )
        (root / "CHANGELOG.md").write_text(
            changelog
            or (
                "# Changelog\n\n## [Unreleased]\n\n"
                "## [2.7.4] - 2026-08-19\n\n"
                "## [0.1.0] - 2026-08-19\n"
            ),
            encoding="utf-8",
        )
        (root / "docs" / "versioning.md").write_text(
            versioning
            or "# Versioning\n\nMaintained package: 2.7.4+1. Tag: v2.7.4.\n",
            encoding="utf-8",
        )

    def test_accepts_consistent_release_metadata_with_zero_major_history(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            self._write_repo(root)
            self.assertEqual(validate_release_metadata(root), [])

    def test_rejects_invalid_or_missing_build_suffix(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            self._write_repo(root, pubspec_version="2.7.4")
            errors = validate_release_metadata(root)
            self.assertTrue(any("positive build number" in error for error in errors))

    def test_requires_matching_in_app_version(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            self._write_repo(root, app_version="2.7.3")
            errors = validate_release_metadata(root)
            self.assertTrue(any("AppConstants.version" in error for error in errors))
            self.assertTrue(any("2.7.4" in error for error in errors))

    def test_requires_exactly_one_semantic_in_app_version_constant(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            self._write_repo(root)
            (root / "lib" / "src" / "core" / "app_constants.dart").write_text(
                "abstract final class AppConstants {\n"
                "  static const String version = 'development';\n"
                "}\n",
                encoding="utf-8",
            )
            errors = validate_release_metadata(root)
            self.assertTrue(any("exactly one semantic" in error for error in errors))

    def test_requires_matching_changelog_release(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            self._write_repo(
                root,
                changelog="# Changelog\n\n## [Unreleased]\n\n## [2.7.3] - 2026-08-18\n",
            )
            errors = validate_release_metadata(root)
            self.assertTrue(any("matching pubspec.yaml" in error for error in errors))

    def test_rejects_duplicate_or_out_of_order_release_entries(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            self._write_repo(
                root,
                changelog=(
                    "# Changelog\n\n## [Unreleased]\n\n"
                    "## [2.7.4] - 2026-08-19\n\n"
                    "## [0.1.0] - 2026-08-18\n\n"
                    "## [2.7.4] - 2026-08-17\n"
                ),
            )
            errors = validate_release_metadata(root)
            self.assertTrue(any("duplicate release 2.7.4" in error for error in errors))
            self.assertTrue(any("newest version first" in error for error in errors))

    def test_rejects_stale_pre_1_policy_for_stable_major(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            self._write_repo(
                root,
                versioning=(
                    "# Versioning\n\n## Pre-1.0 policy\n\n"
                    "Maintained package: 2.7.4+1. Tag: v2.7.4.\n"
                ),
            )
            errors = validate_release_metadata(root)
            self.assertTrue(any("pre-1.0 policy" in error for error in errors))

    def test_requires_current_package_and_tag_in_versioning_guide(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            self._write_repo(root, versioning="# Versioning\n")
            errors = validate_release_metadata(root)
            self.assertTrue(any("2.7.4+1" in error for error in errors))
            self.assertTrue(any("v2.7.4" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
