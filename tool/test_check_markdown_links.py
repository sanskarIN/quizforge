#!/usr/bin/env python3
"""Regression tests for the repository-local Markdown link checker."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

import check_markdown_links


class MarkdownLinkCheckerTest(unittest.TestCase):
    def test_extract_targets_ignores_fenced_code(self) -> None:
        markdown = """
[real](docs/setup.md)

```markdown
[fake](missing.md)
```

[reference]: README.md
"""
        self.assertEqual(
            check_markdown_links.extract_targets(markdown),
            ["docs/setup.md", "README.md"],
        )

    def test_validate_file_accepts_existing_relative_target(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            docs = root / "docs"
            docs.mkdir()
            (docs / "target.md").write_text("# Target\n", encoding="utf-8")
            source = root / "README.md"
            source.write_text("[Target](docs/target.md)\n", encoding="utf-8")

            self.assertEqual(
                check_markdown_links.validate_file(source, root),
                [],
            )

    def test_validate_file_reports_missing_target(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            source = root / "README.md"
            source.write_text("[Missing](docs/missing.md)\n", encoding="utf-8")

            broken = check_markdown_links.validate_file(source, root)

            self.assertEqual(len(broken), 1)
            self.assertEqual(broken[0].target, "docs/missing.md")
            self.assertEqual(broken[0].reason, "local target does not exist")

    def test_validate_file_ignores_external_and_anchor_links(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            source = root / "README.md"
            source.write_text(
                "[Web](https://example.com) [Section](#section)\n",
                encoding="utf-8",
            )

            self.assertEqual(
                check_markdown_links.validate_file(source, root),
                [],
            )

    def test_validate_file_rejects_repository_escape(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            source = root / "README.md"
            source.write_text("[Outside](../outside.md)\n", encoding="utf-8")

            broken = check_markdown_links.validate_file(source, root)

            self.assertEqual(len(broken), 1)
            self.assertEqual(broken[0].reason, "target escapes repository root")


if __name__ == "__main__":
    unittest.main()
