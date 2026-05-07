---
name: Modern Indigo Participation System
colors:
  surface: '#f8f9ff'
  surface-dim: '#ccdbf4'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dde9ff'
  surface-container-highest: '#d5e3fd'
  on-surface: '#0d1c2f'
  on-surface-variant: '#434654'
  inverse-surface: '#233144'
  inverse-on-surface: '#ebf1ff'
  outline: '#737685'
  outline-variant: '#c3c6d6'
  surface-tint: '#1b55d0'
  primary: '#003594'
  on-primary: '#ffffff'
  primary-container: '#004ac6'
  on-primary-container: '#b8c8ff'
  inverse-primary: '#b4c5ff'
  secondary: '#0051d5'
  on-secondary: '#ffffff'
  secondary-container: '#316bf3'
  on-secondary-container: '#fefcff'
  tertiary: '#00472f'
  on-tertiary: '#ffffff'
  tertiary-container: '#006141'
  on-tertiary-container: '#52e1a6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#dbe1ff'
  secondary-fixed-dim: '#b4c5ff'
  on-secondary-fixed: '#00174b'
  on-secondary-fixed-variant: '#003ea8'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f8f9ff'
  on-background: '#0d1c2f'
  surface-variant: '#d5e3fd'
typography:
  heading-lg:
    fontFamily: Inter
    fontSize: 1.8rem
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  heading-md:
    fontFamily: Inter
    fontSize: 1.5rem
    fontWeight: '600'
    lineHeight: '1.3'
  body:
    fontFamily: Inter
    fontSize: 1rem
    fontWeight: '400'
    lineHeight: '1.6'
  label:
    fontFamily: Inter
    fontSize: 0.875rem
    fontWeight: '500'
    lineHeight: '1'
    letterSpacing: 0.01em
  caption:
    fontFamily: Inter
    fontSize: 0.75rem
    fontWeight: '400'
    lineHeight: '1.4'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 56px
---

## Brand & Style

The design system is engineered for 'ProyectoAdminRedes', a participation platform that balances administrative authority with civic accessibility. The brand personality is **Corporate/Modern**—it is dependable, structured, and utilitarian, yet avoids the coldness of traditional bureaucracy through the use of a vibrant indigo-based palette.

The visual language emphasizes transparency and trust. It utilizes a clean aesthetic with generous whitespace and high-contrast typography to ensure that complex administrative data remains legible and actionable for all citizens. The emotional response should be one of confidence and professional efficiency, positioning the platform as a reliable bridge between leadership and the community.

## Colors

The color strategy for this design system revolves around a deep indigo core. The **Primary** indigo provides the weight and seriousness required for administrative tasks, while the **Primary Container** blue offers a more vibrant accent for interactive elements. 

The background uses a subtle lavender-white tint (#faf8ff) to distinguish it from standard "flat" white, reducing eye strain during long periods of use. For information hierarchy, we utilize a tiered text system: **Text Primary** for readability and **Text Muted** for metadata and captions. Functional colors for **Success** and **Danger** are saturated and distinct, ensuring critical status updates are immediately recognizable according to accessibility standards.

## Typography

This design system exclusively utilizes **Inter**, a typeface designed for screens and high-utility interfaces. Its tall x-height and open counters make it the ideal candidate for an administrative dashboard.

The hierarchy is strictly enforced to guide the user through dense information. **Heading LG** is bold and slightly condensed in tracking to command attention for page titles. **Body** text uses a generous line height of 1.6 to ensure long-form participation reports are easy to digest. **Labels** utilize a medium weight and slight tracking to differentiate them from body copy, specifically for use in form fields and navigation menus.

## Layout & Spacing

This design system employs a **fluid grid** model designed for maximum screen utilization on desktop while maintaining responsiveness. We use a 12-column layout with 24px gutters and 32px side margins on larger screens.

The spacing rhythm follows a predictable geometric progression. Use `xs` and `sm` for internal component padding (like button icons or list items). `md` is the standard unit for container padding and spacing between related elements. Use `lg` and `xl` for sections and major layout gaps. The `xxl` unit is reserved for massive structural offsets, such as hero headers or large empty states within the dashboard.

## Elevation & Depth

The design system achieves depth primarily through **tonal layers** and **low-contrast outlines**. To maintain a professional and clean appearance, avoid heavy, dark shadows. 

Surfaces are categorized into three tiers:
1.  **Level 0 (Background):** The base `#faf8ff` layer.
2.  **Level 1 (Surface Pale):** For primary containers and cards, using `#f1f5f9` with a subtle `#e2e8f0` border to define edges.
3.  **Level 2 (Popovers/Modals):** These use the same white/pale surface but introduce a soft ambient shadow (10% opacity primary color tint) to indicate height above the administrative surface.

This approach ensures that the interface feels structural and organized rather than floating or disconnected.

## Shapes

The shape language for this design system is **Rounded**, moving away from "sharp" institutional vibes to something more modern and approachable. 

The `xs` (8px) radius is the standard for small interactive elements like checkboxes or utility buttons. The `md` (18px) radius is used for primary cards and main dashboard containers, creating a softened, sophisticated frame for content. The `lg` (28px) radius is reserved for high-impact elements like search bars, large call-to-action buttons, or decorative badges that need to stand out as distinctive, friendly touchpoints.

## Components

### Buttons
Primary buttons use the `#004ac6` background with `On Primary` white text and an 18px (`md`) radius. For secondary actions, use an outlined style with the `Border Light` color and `#334155` text.

### Inputs & Form Fields
Input fields use a white background with a 12px (`sm`) radius and a 1px border of `Border Light`. On focus, the border should transition to `Primary Container` with a subtle outer glow. Labels must always sit above the field in `Label` typography.

### Cards
Cards are the primary structural unit of the dashboard. They should utilize `Surface Pale` backgrounds, an 18px radius, and no shadow by default, relying on the `Border Light` for definition.

### Chips & Badges
Chips for status (Success/Danger) should use a subtle 10% opacity background of their respective color with high-contrast text. Use the `lg` (28px) radius for a "pill" look that distinguishes them from actionable buttons.

### Participation Lists
Lists should be clean with `sm` spacing between items and a bottom border separating rows. Use the `Text Muted` style for secondary details like timestamps or author names.