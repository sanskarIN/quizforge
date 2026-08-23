from __future__ import annotations

import hashlib
import importlib.util
import struct
import tempfile
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).with_name("generate_platform_branding.py")
SPEC = importlib.util.spec_from_file_location("generate_platform_branding", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
branding = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(branding)


class PlatformBrandingTest(unittest.TestCase):
    def test_render_logo_is_deterministic_and_uses_expected_png_modes(self) -> None:
        opaque_a = branding.render_logo(64)
        opaque_b = branding.render_logo(64)
        transparent = branding.render_logo(64, transparent=True)

        self.assertEqual(
            hashlib.sha256(opaque_a).digest(),
            hashlib.sha256(opaque_b).digest(),
        )
        self.assertEqual(branding._png_dimensions(opaque_a), (64, 64))
        self.assertEqual(branding._png_dimensions(transparent), (64, 64))
        self.assertEqual(opaque_a[25], 2)
        self.assertEqual(transparent[25], 6)

    def test_generate_and_verify_all_supported_platforms(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            outputs = branding.generate(root, branding.SUPPORTED_PLATFORMS)

            self.assertGreaterEqual(len(outputs), 40)
            self.assertEqual(
                branding.verify(root, branding.SUPPORTED_PLATFORMS),
                [],
            )
            self.assertTrue(
                (
                    root
                    / "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
                ).is_file()
            )
            self.assertTrue(
                (
                    root
                    / "ios/Runner/Assets.xcassets/AppIcon.appiconset/"
                    "Icon-App-1024x1024@1x.png"
                ).is_file()
            )
            self.assertTrue((root / "web/icons/Icon-maskable-512.png").is_file())
            self.assertTrue(
                (
                    root
                    / "macos/Runner/Assets.xcassets/AppIcon.appiconset/"
                    "app_icon_1024.png"
                ).is_file()
            )
            self.assertTrue(
                (root / "linux/runner/resources/quizforge.png").is_file()
            )

            ico = (root / "windows/runner/resources/app_icon.ico").read_bytes()
            self.assertEqual(ico[:6], struct.pack("<HHH", 0, 1, 1))

    def test_verify_reports_missing_asset_without_rewriting(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            branding.generate(root, ("web",))
            missing = root / "web/icons/Icon-192.png"
            missing.unlink()

            errors = branding.verify(root, ("web",))

            self.assertTrue(any("Icon-192.png" in error for error in errors))
            self.assertFalse(missing.exists())

    def test_platform_parser_rejects_unknown_names(self) -> None:
        self.assertEqual(
            branding.parse_platforms("android, web,WINDOWS"),
            ("android", "web", "windows"),
        )
        with self.assertRaises(Exception):
            branding.parse_platforms("android,plan9")


if __name__ == "__main__":
    unittest.main()
