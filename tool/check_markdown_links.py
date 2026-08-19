#!/usr/bin/env python3
"""Validate repository-local Markdown link targets without network access."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import unquote, urlsplit

INLINE_LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
REFERENCE_LINK_RE = re.compile(r"^\s*\[[^\]]+\]:\s*(\S+)", re.MULTILINE)
FENCE_RE = re.compile(r"^\s*(```|~~~)")
IGNORED_SCHEMES = {
    "data",
    "ftp",
    "ftps",
    "http",
    "https",
    "mailto",
    "tel",
}


@dataclass(frozen=True)
class BrokenLink:
    source: Path
    target: str
    reason: str

    def render(self, root: Path) -> str:
        try:
            source = self.source.relative_to(root)
        except ValueError:
            source = self.source
        return f"{source}: {self.target!r} ({self.reason})"


def strip_fenced_code(markdown: str) -> str:
    output: list[str] = []
    active_fence: str | None = None
    for line in markdown.splitlines(keepends=True):
        match = FENCE_RE.match(line)
        if match:
            marker = match.group(1)
            if active_fence is None:
                active_fence = marker
            elif marker == active_fence:
                active_fence = None
            output.append("\n" if line.endswith("\n") else "")
            continue
        if active_fence is None:
            output.append(line)
        else:
            output.append("\n" if line.endswith("\n") else "")
    return "".join(output)


def extract_targets(markdown: str) -> list[str]:
    visible = strip_fenced_code(markdown)
    targets = [match.group(1).strip() for match in INLINE_LINK_RE.finditer(visible)]
    targets.extend(match.group(1).strip() for match in REFERENCE_LINK_RE.finditer(visible))
    return targets


def normalize_markdown_target(raw_target: str) -> str:
    target = raw_target.strip()
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1].strip()
    if " " in target and not target.startswith(("#", "/")):
        # Markdown allows an optional title after a destination. Quoted titles are
        # intentionally ignored here so only the actual destination is checked.
        target = target.split(" ", 1)[0]
    return unquote(target)


def is_external_or_ignored(target: str) -> bool:
    if not target or target.startswith("#"):
        return True
    parsed = urlsplit(target)
    if parsed.scheme.lower() in IGNORED_SCHEMES:
        return True
    if target.startswith("//"):
        return True
    return False


def resolve_local_target(source: Path, root: Path, target: str) -> Path:
    parsed = urlsplit(target)
    path_text = parsed.path
    if path_text.startswith("/"):
        candidate = root / path_text.lstrip("/")
    else:
        candidate = source.parent / path_text
    return candidate.resolve()


def validate_file(source: Path, root: Path) -> list[BrokenLink]:
    try:
        markdown = source.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return [BrokenLink(source, "", "file is not valid UTF-8")]

    broken: list[BrokenLink] = []
    for raw_target in extract_targets(markdown):
        target = normalize_markdown_target(raw_target)
        if is_external_or_ignored(target):
            continue

        parsed = urlsplit(target)
        if not parsed.path:
            continue

        candidate = resolve_local_target(source, root, target)
        try:
            candidate.relative_to(root)
        except ValueError:
            broken.append(BrokenLink(source, target, "target escapes repository root"))
            continue

        if not candidate.exists():
            broken.append(BrokenLink(source, target, "local target does not exist"))
    return broken


def markdown_files(root: Path) -> list[Path]:
    excluded_parts = {".dart_tool", ".git", "build"}
    return sorted(
        path
        for path in root.rglob("*.md")
        if not any(part in excluded_parts for part in path.parts)
    )


def run(root: Path) -> list[BrokenLink]:
    return [
        broken
        for source in markdown_files(root)
        for broken in validate_file(source, root)
    ]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Check repository-local Markdown links without network access."
    )
    parser.add_argument(
        "root",
        nargs="?",
        default=".",
        help="repository root to scan (default: current directory)",
    )
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    if not root.is_dir():
        print(f"error: repository root does not exist: {root}", file=sys.stderr)
        return 2

    broken = run(root)
    if broken:
        print(f"Found {len(broken)} broken local Markdown link(s):", file=sys.stderr)
        for item in broken:
            print(f"- {item.render(root)}", file=sys.stderr)
        return 1

    print(f"Checked {len(markdown_files(root))} Markdown file(s): local links are valid.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
