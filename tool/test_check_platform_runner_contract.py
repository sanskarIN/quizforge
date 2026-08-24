#!/usr/bin/env python3
"""Regression tests for the QuizForge generated-runner workflow contract."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from check_platform_runner_contract import (
    CANONICAL_ORG,
    WORKFLOW_PATHS,
    validate_platform_runner_contract,
)


VALID_WORKFLOW = f"""name: Test
jobs:
  build:
    steps:
      - name: Materialize runner
        run: |
          flutter create . --platforms=android --org {CANONICAL_ORG} --no-pub
          git restore --source=HEAD -- pubspec.yaml pubspec.lock analysis_options.yaml
      - name: Resolve
        run: flutter pub get --enforce-lockfile
"""


class PlatformRunnerContractTest(unittest.TestCase):
    def _root(self) -> tuple[tempfile.TemporaryDirectory[str], Path]:
        temporary = tempfile.TemporaryDirectory()
        root = Path(temporary.name)
        for relative_path in WORKFLOW_PATHS:
            path = root / relative_path
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(VALID_WORKFLOW, encoding="utf-8")
        return temporary, root

    def test_valid_contract_passes(self) -> None:
        temporary, root = self._root()
        self.addCleanup(temporary.cleanup)

        self.assertEqual(validate_platform_runner_contract(root), [])

    def test_default_flutter_organization_is_rejected(self) -> None:
        temporary, root = self._root()
        self.addCleanup(temporary.cleanup)
        path = root / WORKFLOW_PATHS[0]
        path.write_text(
            VALID_WORKFLOW.replace(CANONICAL_ORG, "com.example"),
            encoding="utf-8",
        )

        errors = validate_platform_runner_contract(root)

        self.assertTrue(any("com.example" in error for error in errors))
        self.assertTrue(any("canonical organization" in error for error in errors))

    def test_missing_no_pub_is_rejected(self) -> None:
        temporary, root = self._root()
        self.addCleanup(temporary.cleanup)
        path = root / WORKFLOW_PATHS[0]
        path.write_text(
            VALID_WORKFLOW.replace(" --no-pub", ""),
            encoding="utf-8",
        )

        errors = validate_platform_runner_contract(root)

        self.assertTrue(any("--no-pub" in error for error in errors))

    def test_missing_metadata_restore_is_rejected(self) -> None:
        temporary, root = self._root()
        self.addCleanup(temporary.cleanup)
        path = root / WORKFLOW_PATHS[0]
        path.write_text(
            VALID_WORKFLOW.replace(
                "          git restore --source=HEAD -- pubspec.yaml pubspec.lock analysis_options.yaml\n",
                "",
            ),
            encoding="utf-8",
        )

        errors = validate_platform_runner_contract(root)

        self.assertTrue(any("restore reviewed dependency metadata" in error for error in errors))

    def test_missing_enforced_resolution_is_rejected(self) -> None:
        temporary, root = self._root()
        self.addCleanup(temporary.cleanup)
        path = root / WORKFLOW_PATHS[0]
        path.write_text(
            VALID_WORKFLOW.replace(" --enforce-lockfile", ""),
            encoding="utf-8",
        )

        errors = validate_platform_runner_contract(root)

        self.assertTrue(any("enforce the committed" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
