#!/usr/bin/env python3
"""Validate repository-local Markdown links without network access.

The checker intentionally ignores HTTP(S), mailto, data, and pure-fragment links.
It validates inline links/images and reference definitions, while ignoring fenced
code blocks so documentation examples do not create false failures.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
FENCE_RE = re.compile(r"^\s*(```|~~~)")
INLINE_LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
REFERENCE_DEF_RE = re.compile(r"^\s*\[[^\]]+\]:\s*(\S+)")
SKIPPED_SCHEMES = {"http", "https", "mailto", "data", "tel"}


@dataclass(frozen=True)
class BrokenLink:
    source: Path
    line: int
    target: str


def _markdown_files() -> list[Path]:
    ignored = {".git", "build", ".dart_tool"}
    return sorted(
        path
        for path in ROOT.rglob("*.md")
        if not any(part in ignored for part in path.relative_to(ROOT).parts)
    )


def _targets_from_line(line: str) -> list[str]:
    targets = [match.group(1).strip() for match in INLINE_LINK_RE.finditer(line)]
    reference_match = REFERENCE_DEF_RE.match(line)
    if reference_match is not None:
        targets.append(reference_match.group(1).strip())
    return targets


def _normalized_target(raw_target: str) -> str | None:
    target = raw_target.strip().strip("<>")
    if not target:
        return None

    # Markdown permits an optional quoted title after the URL. Keep only the
    # URL portion for ordinary local links.
    if " \"" in target:
        target = target.split(" \"", 1)[0]
    elif " '" in target:
        target = target.split(" '", 1)[0]

    split = urlsplit(target)
    if split.scheme.lower() in SKIPPED_SCHEMES:
        return None
    if split.scheme or split.netloc:
        return None
    if not split.path:
        return None
    return unquote(split.path)


def _resolve(source: Path, target: str) -> Path:
    if target.startswith("/"):
        return ROOT / target.lstrip("/")
    return source.parent / target


def find_broken_links() -> list[BrokenLink]:
    broken: list[BrokenLink] = []
    for markdown in _markdown_files():
        in_fence = False
        for line_number, line in enumerate(
            markdown.read_text(encoding="utf-8").splitlines(), start=1
        ):
            if FENCE_RE.match(line):
                in_fence = not in_fence
                continue
            if in_fence:
                continue

            for raw_target in _targets_from_line(line):
                target = _normalized_target(raw_target)
                if target is None:
                    continue
                resolved = _resolve(markdown, target)
                if not resolved.exists():
                    broken.append(
                        BrokenLink(
                            source=markdown.relative_to(ROOT),
                            line=line_number,
                            target=raw_target,
                        )
                    )
    return broken


def main() -> int:
    broken = find_broken_links()
    if not broken:
        print("Markdown local-link check passed.")
        return 0

    print("Broken repository-local Markdown links:", file=sys.stderr)
    for item in broken:
        print(
            f"- {item.source}:{item.line}: {item.target}",
            file=sys.stderr,
        )
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
