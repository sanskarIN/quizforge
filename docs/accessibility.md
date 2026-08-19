# Accessibility

QuizForge targets WCAG-oriented accessible product behavior across mobile, desktop, and web where Flutter/platform support allows it.

## Current foundations

- Material controls use touch-friendly target sizes.
- The application supports light, dark, and system themes.
- A large-text preference increases application text scaling.
- A reduced-motion preference is persisted for motion-sensitive UI behavior.
- Timers and progress expose semantic labels.
- Correct/incorrect review states use icons and text, not color alone.
- Navigation uses standard Flutter navigation components with keyboard/focus support.
- Most interactive icons provide tooltips or meaningful visible labels.

## Scalable text

Layouts must remain usable with large text. Do not fix text containers to heights that clip scaled labels. Prefer wrapping, flexible layouts, scroll views, and bounded responsive widths.

The large-text preference adds scaling without preventing users from using operating-system text scaling.

## Keyboard and focus

Desktop/web review should verify:

- Tab/Shift+Tab can reach interactive controls in a logical order;
- Enter/Space activate the expected controls;
- focus indicators remain visible;
- dialogs keep focus appropriately and return it after dismissal;
- no critical action requires pointer-only gestures.

Future custom keyboard shortcuts must not shadow common browser/OS accessibility shortcuts.

## Screen readers

Controls whose meaning is not fully represented by visible text should provide semantic labels. Dynamic timer warnings may use live-region behavior sparingly; repeated announcements must not make timed quizzes unusable.

Question content, selected answer state, progress, score, bookmark state, and errors should be understandable without relying on visual position or color.

## Contrast and non-color cues

Use colors from the Material color scheme and manually inspect key surfaces for sufficient contrast. Correct/incorrect, warning, selected, and disabled states need an icon, text, border, shape, or other non-color cue in addition to color.

## Motion

The reduced-motion setting exists to avoid non-essential transitions. New animation should check that preference before introducing movement. Do not add fake loading delays or looping decorative motion that blocks or distracts from quiz content.

## Timed modes

Timed quizzes can create accessibility barriers. QuizForge therefore keeps untimed practice available. Custom quiz configuration should preserve the ability to disable timing and future timer options should not make the default offline experience timing-dependent.

## Forms and validation

Validation errors should be expressed in text near the relevant workflow and remain discoverable by assistive technology. Do not indicate invalid fields only by red outlines.

## Manual release checklist

Before release-candidate status, verify representative flows with:

- platform screen reader where available;
- keyboard-only navigation on desktop/web;
- system text scaling plus QuizForge large text;
- light and dark themes;
- reduced motion enabled;
- narrow phone width and wide desktop width.

Required flows:

1. switch profile;
2. start a quiz;
3. answer every supported question type;
4. skip and finish;
5. review explanations and bookmark;
6. search/filter the question bank;
7. create a question and understand validation errors;
8. import malformed data and read the result report;
9. change appearance/accessibility preferences;
10. navigate About/support links.

Record significant accessibility defects in GitHub issues and add regression tests where automation can reliably cover the behavior.
