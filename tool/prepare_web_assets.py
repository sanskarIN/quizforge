#!/usr/bin/env python3
"""Prepare the pinned Drift Web runtime assets used by QuizForge.

The Flutter Web build can compile without these files, but Drift cannot open the
persistent SQLite database at runtime without a compatible sqlite3 WebAssembly
module and worker. Assets are fetched from the immutable Drift 2.34.3 release.
"""

from __future__ import annotations

import argparse
import os
import tempfile
from pathlib import Path
from urllib.request import Request, urlopen

DRIFT_RELEASE = "2.34.3"
RELEASE_BASE = (
    "https://github.com/simolus3/drift/releases/download/"
    f"drift-{DRIFT_RELEASE}"
)
ASSETS = {
    "sqlite3.wasm": f"{RELEASE_BASE}/sqlite3.wasm",
    "drift_worker.js": f"{RELEASE_BASE}/drift_worker.js",
}
MAX_WASM_BYTES = 8 * 1024 * 1024
MAX_WORKER_BYTES = 2 * 1024 * 1024


def validate_sqlite3_wasm(data: bytes) -> None:
    if not data.startswith(b"\x00asm"):
        raise ValueError("sqlite3.wasm does not have the WebAssembly magic header")
    if len(data) > MAX_WASM_BYTES:
        raise ValueError("sqlite3.wasm exceeds the supported size boundary")


def validate_worker(data: bytes) -> None:
    if not data:
        raise ValueError("drift_worker.js is empty")
    if len(data) > MAX_WORKER_BYTES:
        raise ValueError("drift_worker.js exceeds the supported size boundary")
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError as error:
        raise ValueError("drift_worker.js is not valid UTF-8 JavaScript") from error
    if "drift" not in text.lower():
        raise ValueError("drift_worker.js does not look like a Drift worker")


def validate_asset(name: str, data: bytes) -> None:
    if name == "sqlite3.wasm":
        validate_sqlite3_wasm(data)
    elif name == "drift_worker.js":
        validate_worker(data)
    else:
        raise ValueError(f"unsupported web asset: {name}")


def _download(url: str) -> bytes:
    request = Request(url, headers={"User-Agent": "QuizForge-web-assets/2.7.4"})
    with urlopen(request, timeout=30) as response:
        return response.read(MAX_WASM_BYTES + 1)


def _atomic_write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    file_descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", dir=path.parent
    )
    try:
        with os.fdopen(file_descriptor, "wb") as temporary_file:
            temporary_file.write(data)
            temporary_file.flush()
            os.fsync(temporary_file.fileno())
        os.replace(temporary_name, path)
    except BaseException:
        try:
            os.unlink(temporary_name)
        except FileNotFoundError:
            pass
        raise


def check_assets(destination: Path) -> list[str]:
    errors: list[str] = []
    for name in ASSETS:
        path = destination / name
        if not path.is_file():
            errors.append(f"missing {path.as_posix()}")
            continue
        try:
            validate_asset(name, path.read_bytes())
        except (OSError, ValueError) as error:
            errors.append(f"invalid {path.as_posix()}: {error}")
    return errors


def prepare_assets(destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    for name, url in ASSETS.items():
        target = destination / name
        if target.is_file():
            try:
                validate_asset(name, target.read_bytes())
                print(f"Web runtime asset already valid: {target}")
                continue
            except (OSError, ValueError):
                pass

        print(f"Fetching Drift {DRIFT_RELEASE} Web runtime asset: {name}")
        data = _download(url)
        validate_asset(name, data)
        _atomic_write(target, data)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Prepare or verify QuizForge Drift Web runtime assets."
    )
    parser.add_argument(
        "--destination",
        type=Path,
        default=Path("web"),
        help="Flutter Web runner directory (default: web).",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Verify existing assets without downloading anything.",
    )
    args = parser.parse_args()
    destination = args.destination.resolve()

    if args.check:
        errors = check_assets(destination)
        if errors:
            for error in errors:
                print(f"web-asset error: {error}")
            return 1
        print(f"Drift {DRIFT_RELEASE} Web runtime assets are valid.")
        return 0

    prepare_assets(destination)
    errors = check_assets(destination)
    if errors:
        for error in errors:
            print(f"web-asset error: {error}")
        return 1
    print(f"Drift {DRIFT_RELEASE} Web runtime assets are ready.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
