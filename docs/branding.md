# QuizForge Branding

QuizForge branding is intentionally simple, editable, and suitable for platform-specific icon/splash generation.

## Source artwork

Editable SVG sources live in `assets/branding/`:

- `quizforge_logo.svg` — square shield/question-mark mark suitable as the master icon source.
- `quizforge_splash.svg` — portrait splash composition with product title and credit.

The source artwork uses only repository-authored vector geometry, text, and basic gradients/colors. No third-party trademark or stock illustration is embedded in the source files.

## Visual concept

The mark combines:

- a rounded shield for reliability and focused practice;
- a question mark for quizzes and learning;
- a small spark for the “Forge” idea of building/improving knowledge.

The default palette aligns with the Material 3 seed used by the application. Platform-generated assets may adapt background treatment where operating-system icon masks or splash APIs require it.

## Product credit

The visible project credit is:

**Made by the Sanskar**

Keep this credit on the About screen and appropriate project documentation. Do not place it over interactive quiz content or use it as an intrusive watermark that harms readability.

## Generating platform assets

Do not hand-edit generated Android/iOS/desktop icon raster files independently. Generate the platform-specific set from the master vector source using a documented, reproducible toolchain.

Before committing generated assets:

1. materialize the target platform runners;
2. export the master SVG to a high-resolution lossless source where the chosen generator requires raster input;
3. generate adaptive/masked variants according to the target platform rules;
4. inspect every density/size rather than assuming downscaling is acceptable;
5. verify that icon masks do not crop the shield or spark;
6. verify light/dark splash behavior where the platform supports variants;
7. run the application from a clean install and confirm launch transition behavior;
8. document the generator/version used in the asset commit.

Do not commit signing keys, provisioning data, machine-specific paths, or proprietary font files while generating assets.

## Accessibility

Branding should not be the only carrier of product meaning. Text labels remain available in navigation/About contexts, and splash artwork should not contain critical instructions that disappear before assistive technology can expose them.

## Screenshot policy

Brand artwork is not a substitute for real application screenshots. `docs/screenshots/README.md` defines the required release-build capture set.
