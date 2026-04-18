# Design System Documentation: The Nostalgic Executive

This design system translates the iconic 16-bit era color palette into a high-end, editorial iOS experience. By stripping away the literal interpretations of "gaming"—no pixel art, no heavy beveled buttons—we focus on the sophisticated tonal relationship between deep indigo-purples and warm grays. The result is an interface that feels like a premium digital publication: authoritative, spacious, and subtly nostalgic.

---

### 1. Overview & Creative North Star
**Creative North Star: "The Analog Tech Editorial"**

To move beyond "standard" iOS layouts, this system treats the screen as a series of tactile, stacked sheets. We break the rigid grid through **Intentional Asymmetry**—using generous leading (line height) and oversized display typography that occasionally breaks traditional margins. 

The goal is to evoke the feeling of a high-quality print magazine from the early 90s, reimagined for a modern Retina display. We use depth and tonal layering rather than lines to define structure, ensuring the interface feels "App Store Quality" through its restraint and white space.

---

### 2. Colors & Tonal Depth
We utilize a Material-inspired logic to manage the SNES-inspired palette, ensuring high contrast for accessibility while maintaining a soft, "frosted" aesthetic.

*   **Primary (`#544699`):** Our "Command Color." Used for high-impact actions and key brand moments.
*   **Secondary (`#5f5985`):** A muted lavender used for supporting information and less urgent interactive elements.
*   **Surface Hierarchy:** 
    *   `surface`: `#f9f9f9` (The canvas)
    *   `surface_container_low`: `#f4f3f3` (Subtle nesting)
    *   `surface_container_highest`: `#e2e2e2` (Deepest contrast for inactive states)

#### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section content. Boundaries must be defined solely through background color shifts. For example, a card (`surface_container_lowest`) sits on a background (`surface`) to create a soft, natural edge.

#### Glass & Gradient Rule
To provide "visual soul," primary CTAs should utilize a subtle linear gradient from `primary` to `primary_container`. For floating headers or navigation overlays, apply a **Backdrop Blur (20px)** to a semi-transparent `surface` color to create a premium glassmorphism effect that allows the SNES-inspired tones to bleed through.

---

### 3. Typography
The system pairs two distinct sans-serifs to create an editorial hierarchy.

*   **Display & Headlines (Manrope):** Chosen for its geometric precision and modern "tech" feel. Use `display-lg` (3.5rem) with tight letter-spacing for high-impact screens.
*   **Body & Labels (Inter/SF Pro):** Used for maximum legibility. 
    *   **Body-lg (1rem):** Use for long-form content with a line-height of 1.6 for an "expensive" feel.
    *   **Label-sm (0.6875rem):** Use for micro-copy, always in all-caps with +5% letter spacing to maintain a clean, professional look.

---

### 4. Elevation & Depth
We eschew traditional "drop shadows" in favor of **Tonal Layering** and **Ambient Light**.

*   **The Layering Principle:** Depth is achieved by stacking. Place a `surface_container_lowest` (white) card on a `surface_container_low` section. This creates a soft "lift" without visual noise.
*   **Ambient Shadows:** When a floating element (like a Modal or Action Sheet) is required, use a shadow with a 32px blur, 0px offset, and 6% opacity using the `on_surface` color. It should feel like a soft glow, not a dark smudge.
*   **The Ghost Border:** If a container requires further definition for accessibility, use the `outline_variant` token at **15% opacity**. Never use 100% opaque borders.

---

### 5. Components

#### Buttons
*   **Primary:** Filled with a vertical gradient (`primary` to `primary_container`). Large `xl` (3rem) corner radius. Typography: `title-sm` in `on_primary`.
*   **Secondary:** `surface_container_high` background with `primary` text. No border.
*   **Tertiary:** Ghost style. No background, `primary` text, underlined only on hover/active states.

#### Cards & Lists
*   **Rule:** Forbid divider lines.
*   **Implementation:** Use a `16 (4rem)` spacing gap between content blocks or shift the background from `surface` to `surface_container_low` to indicate a new section.
*   **Corners:** All cards must use the `md` (1.5rem) or `lg` (2rem) corner radius to lean into the friendly, rounded SNES aesthetic.

#### Input Fields
*   **Style:** Minimalist. A subtle `surface_container_highest` bottom-only bar (2px) or a fully enclosed `surface_container_low` box with `DEFAULT` (1rem) rounding.
*   **Focus State:** The bottom bar or border transitions to `primary` with a soft 4px outer glow.

#### Signature Component: The "Mode Toggle"
Given the SNES inspiration, create a custom Segmented Control using `surface_container_high` for the track and a `surface_container_lowest` pill with a soft ambient shadow for the active state.

---

### 6. Do’s and Don’ts

**Do:**
*   Use **intentional asymmetry**. Align a headline to the left but keep body text in a narrower, centered column to create visual interest.
*   Use `primary_fixed_dim` for icons to give them a soft, premium purple tint rather than harsh black.
*   Leverage the `24 (6rem)` spacing for top-of-page margins to allow the layout to "breathe."

**Don't:**
*   **Don't use 1px dividers.** This is the fastest way to make a custom system look like a generic template.
*   **Don't use pure black (#000000).** Use `on_surface` (#1a1c1c) for text to maintain the soft SNES tonal quality.
*   **Don't use pixel-grid icons.** Use smooth, thick-stroke (2pt) SF Symbols or custom SVG icons with rounded caps to match the `md` corner radius of the UI.

---

### 7. Spacing & Rhythm
The system runs on a **4px base grid**, but emphasizes the larger tokens to create a "luxury" feel.
*   **Section Gaps:** Use `12` (3rem) or `16` (4rem).
*   **Internal Padding:** Use `5` (1.25rem) for cards to ensure content doesn't feel cramped against the large `1.5rem` corner radius.