#!/usr/bin/env python3
"""Regression tests for prepare_web_assets.py."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

import prepare_web_assets


class PrepareWebAssetsTest(unittest.TestCase):
    def test_accepts_webassembly_magic_header(self) -> None:
        prepare_web_assets.validate_sqlite3_wasm(b"\x00asm" + b"fixture")

    def test_rejects_non_webassembly_payload(self) -> None:
        with self.assertRaisesRegex(ValueError, "WebAssembly magic"):
            prepare_web_assets.validate_sqlite3_wasm(b"not-wasm")

    def test_accepts_utf8_drift_worker(self) -> None:
        prepare_web_assets.validate_worker(b"// drift worker fixture\n")

    def test_rejects_worker_without_drift_identity(self) -> None:
        with self.assertRaisesRegex(ValueError, "does not look like"):
            prepare_web_assets.validate_worker(b"console.log('worker');\n")

    def test_check_assets_reports_missing_files(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            errors = prepare_web_assets.check_assets(Path(temporary_directory))
            self.assertEqual(len(errors), 2)
            self.assertTrue(any("sqlite3.wasm" in error for error in errors))
            self.assertTrue(any("drift_worker.js" in error for error in errors))

    def test_check_assets_accepts_valid_fixture_files(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            destination = Path(temporary_directory)
            (destination / "sqlite3.wasm").write_bytes(b"\x00asmfixture")
            (destination / "drift_worker.js").write_text(
                "// Drift worker fixture\n", encoding="utf-8"
            )
            self.assertEqual(prepare_web_assets.check_assets(destination), [])


if __name__ == "__main__":
    unittest.main()
