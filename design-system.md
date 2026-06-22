# Design System — calm, minimal, low-strain

*Flutter-ready design tokens for the IIBF micro-learning app. Implements the design pillar in [banking-microlearning-study.md](banking-microlearning-study.md) §5 and themes the screens in the prototype. Tokens are semantic (named by role, not value) so a theme or accent swap is a one-line change.*

---

## 1. Principles → tokens

| Pillar (study §5) | How the tokens enforce it |
|---|---|
| Calm, low-strain | Dark base is **soft** (`#15171C`, not pure black); primary text is **soft-white** (`#E9E7E2`, not pure white) to cut night glare. |
| Minimal | One accent token. Separation by surface + 1px border — **no shadows, no gradients**. |
| Readable when tired | Generous type sizes, two weights only, line-height ≥ 1.6 for body. |
| Consistent across themes | Same token names in dark/light; only values change. Layout never shifts between themes.⁸ |

---

## 2. Color tokens

### 2a. Dark theme (default — built for after-work, low-light study)

| Token | Value | Use |
|---|---|---|
| `bg.base` | `#15171C` | app background (soft dark) |
| `bg.surface` | `#1E222A` | cards, option chips |
| `bg.raised` | `#242933` | review card, modals |
| `text.primary` | `#E9E7E2` | headings, body (soft white) |
| `text.secondary` | `#9CA0A8` | supporting text |
| `text.tertiary` | `#6B6F78` | hints, captions |
| `border` | `#2A2E37` | default 1px separators |
| `border.strong` | `#3A404B` | hover/active emphasis |
| `accent` | `#62C6A8` | primary action, progress, selected |
| `accent.soft` | `rgba(98,198,168,.12)` | selected/active fills, pills |
| `accent.onAccent` | `#0E1714` | text/icon on an accent fill |
| `danger` | `#C97A6D` | wrong answer (calm clay-red, not alarm-red) |
| `warning` | `#D8A24A` | due-soon, caution |

### 2b. Light theme (opt-in)

| Token | Value |
|---|---|
| `bg.base` | `#F7F6F2` (warm off-white, not stark) |
| `bg.surface` | `#FFFFFF` |
| `bg.raised` | `#FFFFFF` |
| `text.primary` | `#20242B` |
| `text.secondary` | `#5C636E` |
| `text.tertiary` | `#8A909A` |
| `border` | `#E4E2DB` |
| `border.strong` | `#D2CFC6` |
| `accent` | `#178A66` (darker teal for contrast on light) |
| `accent.soft` | `rgba(23,138,102,.10)` |
| `accent.onAccent` | `#FFFFFF` |
| `danger` | `#B4513F` |

### 2c. Accent options (swap the `accent` + `accent.soft` tokens only)

The whole identity hinges on one token. Three calm candidates:

| Accent | Dark value | Light value | Feel |
|---|---|---|---|
| **Teal** (default) | `#62C6A8` | `#178A66` | calm, fresh, distinct from corporate banking blue |
| **Navy / blue** | `#5E8BE8` | `#2C5FC0` | trust, conventional banking |
| **Deep green** | `#67C18A` | `#2E8B57` | growth, money, calm |

Nothing else in the system changes when the accent does — that's the point of tokenizing it.

---

## 3. Typography

- **Family:** a humanist sans for legibility — recommend **Inter** (Latin) + **Noto Sans Devanagari** (Hindi/regional). System fonts are a fine fallback.
- **Weights: 400 and 500 only.** Never 600/700 (too heavy for a calm UI).
- **Case:** sentence case everywhere. Never ALL CAPS.

| Token | Size / weight / line-height | Use |
|---|---|---|
| `type.display` | 22 / 500 / 1.25 | lesson title, big moments |
| `type.title` | 18 / 500 / 1.3 | screen titles |
| `type.heading` | 16 / 500 / 1.35 | card titles, questions |
| `type.body` | 14 / 400 / 1.6 | concept text, options |
| `type.bodySm` | 13 / 400 / 1.55 | scenarios, secondary |
| `type.caption` | 12 / 400 / 1.5 | sublabels |
| `type.micro` | 11 / 400 / 1.4 | hints, pills (floor — never smaller) |

Respect OS text-scaling; layouts must reflow, not clip.

---

## 4. Spacing, radius, sizing, motion

**Spacing** (4-pt base): `4 · 8 · 12 · 16 · 20 · 24 · 32`. Vertical rhythm in 8s; component-internal gaps in 4s. Be generous — whitespace is the calm.

**Radius:** `sm 8 · md 10 · lg 14 · xl 20 · pill 999`. Cards `lg`, option chips/buttons `md–lg`, pills/ring `pill`.

**Sizing:** minimum tap target **44×44**. Primary button height 48. Icon sizes 16–24 (Tabler-style outline; never filled).

**Elevation:** none. No drop shadows. Separate surfaces with `bg.surface` + 1px `border`. (Avoids the eye-fatiguing contrast and the streaming/flicker of shadows.)

**Motion (calm, never bouncy):**
| Token | Value |
|---|---|
| `motion.quick` | 120ms |
| `motion.base` | 200ms |
| `motion.gentle` | 320ms (card/screen transitions) |
| `motion.easing` | `cubic-bezier(0.2, 0, 0, 1)` (ease-out, no overshoot) |

Honor "reduce motion": fall back to instant cross-fades.

---

## 5. Component tokens

| Component | Spec |
|---|---|
| **Primary button** | `accent` fill, `accent.onAccent` text, weight 500, radius `lg`, height 48, full-width |
| **Secondary button** | transparent fill, 1px `border`, `text.primary`, radius `lg` |
| **Option chip** | 1px `border`, radius `md`, `bg` transparent → selected: `accent` border + `accent.soft` fill + trailing check; wrong: `danger` border + 8% danger fill |
| **Pill / tag** | `accent.soft` fill, `accent` text, radius `pill`, `type.micro` |
| **Card** | `bg.surface`, radius `lg`, padding 16, 1px `border` (optional) |
| **Progress ring** | track `border`, fill `accent`, stroke 6–7, rounded cap |
| **Rating buttons** (SRS) | secondary style; "Good" gets `accent` border + `accent.soft` |

---

## 6. Flutter mapping

Use Material 3 `ColorScheme` for standard roles + a `ThemeExtension` for the app-specific tokens (the ones Material doesn't model: `accentSoft`, `textTertiary`, `danger`-as-calm, ring colors).

```dart
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color bgBase, bgSurface, bgRaised;
  final Color textPrimary, textSecondary, textTertiary;
  final Color border, borderStrong, accent, accentSoft, onAccent, danger;
  const AppTokens({ required this.bgBase, required this.bgSurface, /* … */ });

  static const dark = AppTokens(
    bgBase: Color(0xFF15171C), bgSurface: Color(0xFF1E222A), bgRaised: Color(0xFF242933),
    textPrimary: Color(0xFFE9E7E2), textSecondary: Color(0xFF9CA0A8), textTertiary: Color(0xFF6B6F78),
    border: Color(0xFF2A2E37), borderStrong: Color(0xFF3A404B),
    accent: Color(0xFF62C6A8), accentSoft: Color(0x1F62C6A8), onAccent: Color(0xFF0E1714),
    danger: Color(0xFFC97A6D),
  );
  static const light = AppTokens(/* §2b values */);

  @override AppTokens copyWith({ /* … */ }) => /* … */;
  @override AppTokens lerp(ThemeExtension<AppTokens>? o, double t) => /* lerp each color */;
}

ThemeData buildTheme(AppTokens t, TextTheme base) => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: t.bgBase,
  extensions: [t],
  textTheme: base.apply(fontFamily: 'Inter',
    bodyColor: t.textPrimary, displayColor: t.textPrimary),
);
```

Access in widgets via `Theme.of(context).extension<AppTokens>()!`. Swapping the accent = passing a `dark.copyWith(accent: navy, accentSoft: navySoft)`; nothing else changes.

---

## 7. Accessibility checks (built into the tokens)

- Body contrast: `text.primary` on `bg.base` ≈ 13:1; `text.secondary` ≈ 6:1 — both clear WCAG AA.
- Never pure-white text on the dark base (glare); never pure-black on light.
- Accent is for fills/large text, not small body copy on `bg.base` (contrast too low at small sizes) — keep accent text ≥ `type.heading` or on `accent.soft`.
- Min tap target 44; full audio mode means the UI is never the only path (study §5.5).
- All color-encoded states (correct/wrong) also carry an icon + text — never colour alone.
