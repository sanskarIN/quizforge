from __future__ import annotations

import argparse
import math
import struct
import zlib
from pathlib import Path
from typing import Iterable

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
CREAM = (247, 242, 250, 255)
PURPLE_A = (103, 80, 164, 255)
PURPLE_B = (79, 55, 139, 255)
WHITE = (255, 255, 255, 255)
GOLD = (255, 221, 0, 255)
TRANSPARENT = (0, 0, 0, 0)

SUPPORTED_PLATFORMS = ("android", "ios", "web", "windows", "macos", "linux")


def _chunk(kind: bytes, data: bytes) -> bytes:
    payload = kind + data
    return (
        struct.pack(">I", len(data))
        + payload
        + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)
    )


def encode_png(width: int, height: int, pixels: bytes, *, alpha: bool) -> bytes:
    if width <= 0 or height <= 0:
        raise ValueError("PNG dimensions must be positive.")
    channels = 4 if alpha else 3
    expected = width * height * channels
    if len(pixels) != expected:
        mode = "RGBA" if alpha else "RGB"
        raise ValueError(f"Expected {expected} {mode} bytes, got {len(pixels)}.")
    rows = bytearray()
    stride = width * channels
    for y in range(height):
        rows.append(0)
        start = y * stride
        rows.extend(pixels[start : start + stride])
    color_type = 6 if alpha else 2
    header = struct.pack(">IIBBBBB", width, height, 8, color_type, 0, 0, 0)
    return (
        PNG_SIGNATURE
        + _chunk(b"IHDR", header)
        + _chunk(b"IDAT", zlib.compress(bytes(rows), level=9))
        + _chunk(b"IEND", b"")
    )


def _point_in_polygon(
    x: float,
    y: float,
    points: tuple[tuple[float, float], ...],
) -> bool:
    inside = False
    j = len(points) - 1
    for i, (xi, yi) in enumerate(points):
        xj, yj = points[j]
        intersects = ((yi > y) != (yj > y)) and (
            x < (xj - xi) * (y - yi) / ((yj - yi) or 1e-12) + xi
        )
        if intersects:
            inside = not inside
        j = i
    return inside


def _distance_to_segment(
    x: float,
    y: float,
    ax: float,
    ay: float,
    bx: float,
    by: float,
) -> float:
    vx, vy = bx - ax, by - ay
    wx, wy = x - ax, y - ay
    length2 = vx * vx + vy * vy
    if length2 == 0:
        return math.hypot(x - ax, y - ay)
    t = max(0.0, min(1.0, (wx * vx + wy * vy) / length2))
    px, py = ax + t * vx, ay + t * vy
    return math.hypot(x - px, y - py)


def _blend(
    a: tuple[int, int, int, int],
    b: tuple[int, int, int, int],
    t: float,
) -> tuple[int, int, int, int]:
    t = max(0.0, min(1.0, t))
    return tuple(round(av + (bv - av) * t) for av, bv in zip(a, b))  # type: ignore[return-value]


def _brand_pixel(
    x: float,
    y: float,
    *,
    transparent: bool,
) -> tuple[int, int, int, int]:
    base = TRANSPARENT if transparent else CREAM
    shield = (
        (0.18, 0.25),
        (0.30, 0.17),
        (0.50, 0.13),
        (0.70, 0.17),
        (0.82, 0.25),
        (0.82, 0.51),
        (0.75, 0.69),
        (0.62, 0.80),
        (0.50, 0.86),
        (0.38, 0.80),
        (0.25, 0.69),
        (0.18, 0.51),
    )
    color = base
    if _point_in_polygon(x, y, shield):
        color = _blend(PURPLE_A, PURPLE_B, (x + y) / 2)

    # Question-mark hook: upper arc plus a descending stem.
    cx, cy, radius = 0.52, 0.39, 0.145
    dx, dy = x - cx, y - cy
    radial = math.hypot(dx, dy)
    angle = math.atan2(dy, dx)
    arc = abs(radial - radius) <= 0.047 and -2.9 <= angle <= 1.20
    stem = _distance_to_segment(x, y, 0.625, 0.475, 0.515, 0.615) <= 0.045
    if arc or stem:
        color = WHITE
    if math.hypot(x - 0.49, y - 0.705) <= 0.043:
        color = WHITE

    # Small spark.
    sx, sy = abs(x - 0.735), abs(y - 0.235)
    if sx + sy <= 0.055:
        color = GOLD
    return color


def render_logo(size: int, *, transparent: bool = False) -> bytes:
    if size < 16 or size > 2048:
        raise ValueError("Branding size must be between 16 and 2048 pixels.")
    pixels = bytearray()
    for row in range(size):
        y = (row + 0.5) / size
        for col in range(size):
            x = (col + 0.5) / size
            color = _brand_pixel(x, y, transparent=transparent)
            pixels.extend(color if transparent else color[:3])
    return encode_png(size, size, bytes(pixels), alpha=transparent)


def encode_ico(png: bytes, size: int = 256) -> bytes:
    if not png.startswith(PNG_SIGNATURE):
        raise ValueError("ICO payload must be a PNG.")
    dimension = 0 if size == 256 else size
    header = struct.pack("<HHH", 0, 1, 1)
    entry = struct.pack(
        "<BBBBHHII",
        dimension,
        dimension,
        0,
        0,
        1,
        32,
        len(png),
        22,
    )
    return header + entry + png


def _write(path: Path, data: bytes | str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if isinstance(data, str):
        path.write_text(data, encoding="utf-8", newline="\n")
    else:
        path.write_bytes(data)


def _logo_cache(
    sizes: Iterable[int],
    *,
    transparent: bool = False,
) -> dict[int, bytes]:
    return {
        size: render_logo(size, transparent=transparent)
        for size in sorted(set(sizes))
    }


ANDROID_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}
MACOS_ICONS = {
    f"app_icon_{size}.png": size
    for size in (16, 32, 64, 128, 256, 512, 1024)
}
WEB_ICONS = {
    "favicon.png": 32,
    "icons/Icon-192.png": 192,
    "icons/Icon-512.png": 512,
    "icons/Icon-maskable-192.png": 192,
    "icons/Icon-maskable-512.png": 512,
}


def _android(root: Path) -> list[Path]:
    sizes = set(ANDROID_SIZES.values()) | {256}
    cache = _logo_cache(sizes)
    outputs: list[Path] = []
    base = root / "android/app/src/main/res"
    for folder, size in ANDROID_SIZES.items():
        path = base / folder / "ic_launcher.png"
        _write(path, cache[size])
        outputs.append(path)
    splash = base / "drawable" / "launch_image.png"
    _write(splash, render_logo(256, transparent=True))
    outputs.append(splash)
    xml = """<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item>
        <shape android:shape="rectangle">
            <solid android:color="#F7F2FA" />
        </shape>
    </item>
    <item>
        <bitmap android:gravity="center" android:src="@drawable/launch_image" />
    </item>
</layer-list>
"""
    for folder in ("drawable", "drawable-v21"):
        path = base / folder / "launch_background.xml"
        _write(path, xml)
        outputs.append(path)
    return outputs


def _ios(root: Path) -> list[Path]:
    base = root / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    cache = _logo_cache(IOS_ICONS.values())
    outputs: list[Path] = []
    for name, size in IOS_ICONS.items():
        path = base / name
        _write(path, cache[size])
        outputs.append(path)
    launch_base = root / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    for name, size in (
        ("LaunchImage.png", 256),
        ("LaunchImage@2x.png", 512),
        ("LaunchImage@3x.png", 768),
    ):
        path = launch_base / name
        _write(path, render_logo(size, transparent=True))
        outputs.append(path)
    return outputs


def _web(root: Path) -> list[Path]:
    base = root / "web"
    cache = _logo_cache(WEB_ICONS.values())
    outputs: list[Path] = []
    for name, size in WEB_ICONS.items():
        path = base / name
        _write(path, cache[size])
        outputs.append(path)
    return outputs


def _windows(root: Path) -> list[Path]:
    png = render_logo(256)
    path = root / "windows/runner/resources/app_icon.ico"
    _write(path, encode_ico(png))
    return [path]


def _macos(root: Path) -> list[Path]:
    base = root / "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    cache = _logo_cache(MACOS_ICONS.values())
    outputs: list[Path] = []
    for name, size in MACOS_ICONS.items():
        path = base / name
        _write(path, cache[size])
        outputs.append(path)
    return outputs


def _linux(root: Path) -> list[Path]:
    path = root / "linux/runner/resources/quizforge.png"
    _write(path, render_logo(256))
    return [path]


GENERATORS = {
    "android": _android,
    "ios": _ios,
    "web": _web,
    "windows": _windows,
    "macos": _macos,
    "linux": _linux,
}


def generate(root: Path, platforms: Iterable[str]) -> list[Path]:
    outputs: list[Path] = []
    for platform in platforms:
        outputs.extend(GENERATORS[platform](root))
    return outputs


def _png_dimensions(data: bytes) -> tuple[int, int] | None:
    if len(data) < 24 or not data.startswith(PNG_SIGNATURE):
        return None
    return struct.unpack(">II", data[16:24])


def verify(root: Path, platforms: Iterable[str]) -> list[str]:
    errors: list[str] = []

    def expect_png(path: Path, size: int) -> None:
        if not path.is_file():
            errors.append(f"missing {path.relative_to(root)}")
            return
        dimensions = _png_dimensions(path.read_bytes())
        if dimensions != (size, size):
            errors.append(
                f"invalid PNG {path.relative_to(root)}: {dimensions!r}"
            )

    for platform in platforms:
        if platform == "android":
            android_base = root / "android/app/src/main/res"
            for folder, size in ANDROID_SIZES.items():
                expect_png(android_base / folder / "ic_launcher.png", size)
            expect_png(android_base / "drawable/launch_image.png", 256)
            for folder in ("drawable", "drawable-v21"):
                xml_path = android_base / folder / "launch_background.xml"
                if not xml_path.is_file():
                    errors.append(f"missing {xml_path.relative_to(root)}")
                else:
                    xml = xml_path.read_text(encoding="utf-8")
                    if (
                        "@drawable/launch_image" not in xml
                        or "#F7F2FA" not in xml
                    ):
                        errors.append(
                            "invalid Android splash XML "
                            f"{xml_path.relative_to(root)}"
                        )
        elif platform == "ios":
            for name, size in IOS_ICONS.items():
                expect_png(
                    root / "ios/Runner/Assets.xcassets/AppIcon.appiconset" / name,
                    size,
                )
            launch_base = root / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
            for name, size in (
                ("LaunchImage.png", 256),
                ("LaunchImage@2x.png", 512),
                ("LaunchImage@3x.png", 768),
            ):
                expect_png(launch_base / name, size)
        elif platform == "web":
            for name, size in WEB_ICONS.items():
                expect_png(root / "web" / name, size)
        elif platform == "windows":
            path = root / "windows/runner/resources/app_icon.ico"
            if (
                not path.is_file()
                or path.read_bytes()[:6] != struct.pack("<HHH", 0, 1, 1)
            ):
                errors.append(f"invalid ICO {path.relative_to(root)}")
        elif platform == "macos":
            for name, size in MACOS_ICONS.items():
                expect_png(
                    root / "macos/Runner/Assets.xcassets/AppIcon.appiconset" / name,
                    size,
                )
        elif platform == "linux":
            expect_png(root / "linux/runner/resources/quizforge.png", 256)
    return errors


def parse_platforms(value: str) -> tuple[str, ...]:
    names = tuple(part.strip().lower() for part in value.split(",") if part.strip())
    if not names:
        raise argparse.ArgumentTypeError("At least one platform is required.")
    unknown = sorted(set(names) - set(SUPPORTED_PLATFORMS))
    if unknown:
        raise argparse.ArgumentTypeError(
            f"Unsupported platform(s): {', '.join(unknown)}"
        )
    return names


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate deterministic QuizForge platform branding."
    )
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument(
        "--platforms",
        type=parse_platforms,
        default=SUPPORTED_PLATFORMS,
        help="Comma-separated platform list.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Validate generated assets without rewriting them.",
    )
    args = parser.parse_args()
    root = args.root.resolve()
    if args.check:
        errors = verify(root, args.platforms)
        if errors:
            for error in errors:
                print(f"ERROR: {error}")
            return 1
        print("QuizForge platform branding check passed.")
        return 0
    outputs = generate(root, args.platforms)
    print(f"Generated {len(outputs)} QuizForge branding files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
