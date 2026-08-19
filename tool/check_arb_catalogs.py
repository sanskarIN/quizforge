#!/usr/bin/env python3
"""Validate QuizForge ARB localization catalogs using only Python stdlib."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class CatalogProblem:
    path: Path
    message: str

    def render(self, root: Path) -> str:
        try:
            relative = self.path.relative_to(root)
        except ValueError:
            relative = self.path
        return f"{relative}: {self.message}"


class DuplicateKeyError(ValueError):
    pass


def _reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def load_catalog(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    value = json.loads(text, object_pairs_hook=_reject_duplicate_keys)
    if not isinstance(value, dict):
        raise ValueError("ARB root must be a JSON object")
    return value


def message_keys(catalog: dict[str, Any]) -> set[str]:
    return {
        key
        for key in catalog
        if not key.startswith("@")
    }


def validate_catalog(path: Path, template_keys: set[str] | None = None) -> list[CatalogProblem]:
    problems: list[CatalogProblem] = []
    try:
        catalog = load_catalog(path)
    except (OSError, UnicodeDecodeError, json.JSONDecodeError, DuplicateKeyError, ValueError) as error:
        return [CatalogProblem(path, str(error))]

    locale = catalog.get("@@locale")
    if not isinstance(locale, str) or not locale.strip():
        problems.append(CatalogProblem(path, "missing non-empty @@locale"))

    keys = message_keys(catalog)
    if not keys:
        problems.append(CatalogProblem(path, "catalog contains no messages"))

    for key in sorted(keys):
        value = catalog[key]
        if not isinstance(value, str):
            problems.append(CatalogProblem(path, f"message {key!r} must be a string"))
        elif not value.strip():
            problems.append(CatalogProblem(path, f"message {key!r} must not be empty"))

    for key in sorted(catalog):
        if key.startswith("@@"):
            continue
        if key.startswith("@"):
            message_key = key[1:]
            if message_key not in keys:
                problems.append(
                    CatalogProblem(
                        path,
                        f"metadata {key!r} has no matching message {message_key!r}",
                    )
                )
            metadata = catalog[key]
            if not isinstance(metadata, dict):
                problems.append(CatalogProblem(path, f"metadata {key!r} must be an object"))

    if template_keys is not None:
        missing = sorted(template_keys - keys)
        extra = sorted(keys - template_keys)
        for key in missing:
            problems.append(CatalogProblem(path, f"missing template message {key!r}"))
        for key in extra:
            problems.append(CatalogProblem(path, f"message {key!r} is not present in template"))

    return problems


def run(root: Path, template_relative: str = "lib/l10n/app_en.arb") -> list[CatalogProblem]:
    template = (root / template_relative).resolve()
    if not template.is_file():
        return [CatalogProblem(template, "template catalog does not exist")]

    template_problems = validate_catalog(template)
    if template_problems:
        return template_problems

    template_keys = message_keys(load_catalog(template))
    catalogs = sorted((root / "lib" / "l10n").glob("*.arb"))
    problems: list[CatalogProblem] = []
    for catalog in catalogs:
        if catalog.resolve() == template:
            continue
        problems.extend(validate_catalog(catalog, template_keys=template_keys))
    return problems


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Validate QuizForge ARB localization catalogs.")
    parser.add_argument("root", nargs="?", default=".", help="repository root")
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    if not root.is_dir():
        print(f"error: repository root does not exist: {root}", file=sys.stderr)
        return 2

    problems = run(root)
    if problems:
        print(f"Found {len(problems)} ARB catalog problem(s):", file=sys.stderr)
        for problem in problems:
            print(f"- {problem.render(root)}", file=sys.stderr)
        return 1

    catalog_count = len(list((root / "lib" / "l10n").glob("*.arb")))
    print(f"Validated {catalog_count} ARB catalog(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
