---
tokens:
  colors:
    background:
      surface-dark: "#0f172a" # deep indigo/near-black used for hero and dark surfaces
      slate-900: "#1e293b"
      white: "#ffffff"
      pale: "#f1f5f9"
    primary:
      blue-600: "#2563eb"
      indigo-900: "#1e3a8a"
      sky-400: "#38bdf8"
      soft-blue: "#dbeafe"
    neutral:
      text: "#334155"
      muted: "#64748b"
      border: "#e2e8f0"
      steel: "#cbd5e1"
    success:
      green-500: "#10b981"
      green-600: "#059669"
    danger:
      red-700: "#b91c1c"
      red-100: "#fee2e2"

  typography:
    font-family: "Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif"
    scale:
      display: "clamp(2.4rem, 6vw, 5rem)" # large responsive hero typography
      heading-lg: "1.8rem"
      heading-md: "1.5rem"
      body-lg: "1.08rem"
      body: "1rem"
      label: "0.875rem"
      caption: "0.78rem"
    weights:
      regular: 400
      medium: 500
      bold: 700

  spacing:
    xs: "4px"
    sm: "8px"
    md: "16px"
    lg: "24px"
    xl: "32px"
    xxl: "56px"
    form-input-vertical: "0.75rem"

  radii:
    pill: "999px"
    lg: "28px"
    md: "22px"
    card: "18px"
    sm: "12px"
    xs: "8px"

  elevation:
    overlay: "0 24px 80px rgba(2,6,23,0.42)"
    elevated-card: "0 18px 44px rgba(2,6,23,0.18)"
    shallow: "0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1)"
    focus-ring: "0 0 0 3px rgba(59,130,246,0.1)"

  motion:
    duration-short: "0.12s"
    duration-medium: "0.2s"
    easing: "cubic-bezier(.2,.9,.25,1)"

  layout:
    container-max: "1180px"
    sidebar-width: "360px"
    breakpoints:
      sm: "780px"
      md: "860px"
      lg: "900px"

  form:
    border: "1px solid #cbd5e1"
    input-padding: "0.75rem"
    input-radius: "8px"

---

Design Summary

This product uses a restrained, professional design system rooted in a deep indigo/blue palette with neutral, desaturated grays for content and subtle, bright accents for interactive cues. The overall voice is modern and calm — confident geometry, soft rounded corners, and layered elevation combine to produce a workspace that feels approachable while remaining focused and data-forward.

Color System

- Core: Deep indigo / near-black (surface-dark) anchors hero areas and high-contrast UI. Primary blues (blue-600 and indigo-900) form the brand color backbone for actions and highlights.
- Accent: A cool sky blue (#38bdf8) and a soft pale-blue surface are used sparingly for decorative gradients and subtle highlights.
- Neutrals: Text and UI surfaces use a neutral scale from #334155 (primary text) down to #f1f5f9 (pale surfaces). Borders use a light steel tint to separate surface planes.
- Status: Greens for success (10b981 / 059669) and a clear red for errors (b91c1c with a pale error surface) provide immediate semantic feedback.

Typography

- The UI uses Inter with a system fallback stack for a clean geometric sans aesthetic. The type scale is intentionally large for key headings (responsive display scale) and comfortable for dense data views (body around 1rem / 16px).
- Sizing strategy: Use the display clamp only for hero or dashboard title areas where a responsive, attention-grabbing headline is needed. Use heading-lg/heading-md for section titles and body / body-lg for content.

Spacing & Layout

- A compact-but-comfortable spacing rhythm is used: 8px base increments with commonly used paddings at 16px and 32px. Form controls and cards prefer slightly larger internal padding for readability.
- Containers are constrained (container-max 1180px) with a two-column pattern where the sidebar is ~360px on larger breakpoints. Breakpoints at ~780–900px determine column collapse and compact modes.

Elevation & Surfaces

- Elevation is shallow and soft. The deepest elevation (overlay) uses a large, blurred shadow with a cool tint to create an atmospheric backdrop for hero cards. Elevated cards use a softer, lower-opacity shadow to lift panels off a light surface.
- Focused states use a subtle blue focus-ring that reads as a halo rather than a hard outline.

Radii

- The system uses a mix of large rounded containers and small, approachable controls: pill radii for avatars and pills, 18–28px radii for cards, and 8–12px radii for form elements and controls. This gives layouts a friendly, non-technical feel without becoming bubble-like.

Forms & Controls

- Inputs use an 8px radius, 1px neutral border, and a 0.75rem vertical padding to balance density and tap targets. Focus introduces a soft blue halo (focus-ring) rather than intensifying the border color alone.
- Primary actions use the saturated blue (blue-600) for filled buttons with high contrast text; secondary or neutral actions use soft backgrounds or bordered styles on pale surfaces.

Motion

- Motion is minimal and purposeful: 0.2s transitions for border and shadow changes keeps interactions snappy but calm. Use the provided easing for natural deceleration on hover/press transitions.

Accessibility & Contrast

- Use the deep neutral (#334155) on pale backgrounds for body text to meet comfortable contrast. Reserve white on the deep indigo surface for high-contrast headlines and primary inverted controls.
- For status indicators and focus states, ensure the accessible contrast ratios (WCAG AA/AAA) by increasing weight or adding an outer glow when necessary for small UI elements.

Usage Guidance

- Brand/Primary: Use blue-600 as the primary call-to-action color. Use sky-400 for subtle decorative accents (gradients, small indicators), and soft-blue as a very light “informational” surface.
- Cards: Use card radii (18px) and elevated-card shadow for standard content panels; use overlay shadow for hero or prominent callout panels.
- Buttons: Primary filled: background blue-600, text white. Secondary: white background, steel border. Use soft-blue backgrounds only for informational badges or subtle alerts.

Examples (implementation patterns)

- Dashboard hero: surface-dark background, large responsive display typography, radial sky-blue decorative gradient, elevated overlay shadow and rounded 28px container.
- Card list: pale surface (#f1f5f9 or white), card radius 18px, subtle border #e2e8f0, elevated-card shadow. Spacing: 18–24px interior padding, 12–14px gaps between elements.
- Form input: white background, 1px #cbd5e1 border, 8px radius, 0.75rem vertical padding, focus-ring on focus.

Tokens Intent Notes

- The tokens above are intentionally semantic (primary/neutral/success/danger) rather than purely numerical to make them easy to apply across components. Use the radii and elevation tokens consistently: small controls (xs, sm) vs. large containers (card, lg).

When to deviate

- Slight deviations are permitted to meet accessibility (contrast) or content density needs — for example, increase font-weight or use a darker neutral for small captions to meet contrast thresholds. Keep deviations explicit and documented in component-level guidance.

Design goals

- Create a productive, calm workspace where data is visible but not noisy.
- Favor clarity and hierarchy: large, responsive headings for orientation, restrained color accents for actions, and soft elevation to separate context.

End of file
