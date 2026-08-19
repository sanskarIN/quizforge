#!/usr/bin/env python3
"""Regression tests for QuizForge ARB catalog validation."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

import check_arb_catalogs


class ArbCatalogCheckerTest(unittest.TestCase):
    def _write_catalog(self, root: Path, name: str, value: dict[str, object]) -> Path:
        directory = root / "lib" / "l10n"
        directory.mkdir(parents=True, exist_ok=True)
        path = directory / name
        path.write_text(json.dumps(value, indent=2), encoding="utf-8")
        return path

    def test_valid_catalog_passes(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            path = self._write_catalog(
                root,
                "app_en.arb",
                {"@@locale": "en", "appName": "QuizForge"},
            )
            self.assertEqual(check_arb_catalogs.validate_catalog(path), [])

    def test_empty_message_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            path = self._write_catalog(
                root,
                "app_en.arb",
                {"@@locale": "en", "appName": "   "},
            )
            problems = check_arb_catalogs.validate_catalog(path)
            self.assertTrue(any("must not be empty" in problem.message for problem in problems))

    def test_orphan_metadata_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            path = self._write_catalog(
                root,
                "app_en.arb",
                {
                    "@@locale": "en",
                    "appName": "QuizForge",
                    "@missing": {"description": "orphan"},
                },
            )
            problems = check_arb_catalogs.validate_catalog(path)
            self.assertTrue(any("no matching message" in problem.message for problem in problems))

    def test_translation_must_match_template_keys(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            self._write_catalog(
                root,
                "app_en.arb",
                {"@@locale": "en", "appName": "QuizForge", "home": "Home"},
            )
            self._write_catalog(
                root,
                "app_hi.arb",
                {"@@locale": "hi", "appName": "QuizForge", "extra": "Extra"},
            )
            problems = check_arb_catalogs.run(root)
            messages = {problem.message for problem in problems}
            self.assertIn("missing template message 'home'", messages)
            self.assertIn("message 'extra' is not present in template", messages)

    def test_duplicate_json_keys_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            directory = root / "lib" / "l10n"
            directory.mkdir(parents=True)
            path = directory / "app_en.arb"
            path.write_text(
                '{"@@locale":"en","home":"Home","home":"Again"}',
                encoding="utf-8",
            )
            problems = check_arb_catalogs.validate_catalog(path)
            self.assertEqual(len(problems), 1)
            self.assertIn("duplicate JSON key", problems[0].message)


if __name__ == "__main__":
    unittest.main()
