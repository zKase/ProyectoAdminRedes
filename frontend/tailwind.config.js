/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts,tsx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "error-container": "#ffdad6",
        "tertiary-fixed-dim": "#4edea3",
        "on-background": "#0d1c2f",
        "surface-container-lowest": "#ffffff",
        "secondary-fixed": "#dbe1ff",
        "error": "#ba1a1a",
        "on-surface-variant": "#434654",
        "secondary": "#0051d5",
        "surface-bright": "#f8f9ff",
        "on-error-container": "#93000a",
        "on-tertiary-fixed-variant": "#005236",
        "on-primary-fixed-variant": "#003ea8",
        "surface-container-high": "#dde9ff",
        "on-surface": "#0d1c2f",
        "surface-container-highest": "#d5e3fd",
        "surface-tint": "#1b55d0",
        "tertiary-fixed": "#6ffbbe",
        "secondary-fixed-dim": "#b4c5ff",
        "on-primary": "#ffffff",
        "background": "#f8f9ff",
        "surface-container-low": "#eff4ff",
        "inverse-primary": "#b4c5ff",
        "primary-container": "#1a6bc7",
        "on-secondary-fixed": "#00174b",
        "surface-variant": "#d5e3fd",
        "on-error": "#ffffff",
        "on-tertiary": "#ffffff",
        "tertiary": "#00472f",
        "secondary-container": "#316bf3",
        "on-tertiary-fixed": "#002113",
        "primary-fixed": "#dbe1ff",
        "tertiary-container": "#006141",
        "on-secondary": "#ffffff",
        "on-secondary-container": "#fefcff",
        "outline-variant": "#c3c6d6",
        "surface-dim": "#ccdbf4",
        "on-secondary-fixed-variant": "#003ea8",
        "inverse-on-surface": "#ebf1ff",
        "on-primary-fixed": "#00174b",
        "primary": "#0052b5",
        "outline": "#737685",
        "primary-fixed-dim": "#b4c5ff",
        "on-tertiary-container": "#52e1a6",
        "on-primary-container": "#b8c8ff",
        "inverse-surface": "#233144",
        "surface": "#f8f9ff",
        "surface-container": "#e6eeff"
      },
      borderRadius: {
        DEFAULT: "0.25rem",
        lg: "0.5rem",
        xl: "0.75rem",
        full: "9999px"
      },
      spacing: {
        xs: "4px",
        sm: "8px",
        md: "16px",
        lg: "24px",
        xl: "32px",
        xxl: "56px"
      },
      fontFamily: {
        label: ["Inter"],
        caption: ["Inter"],
        body: ["Inter"],
        "heading-lg": ["Inter"],
        "heading-md": ["Inter"]
      },
      fontSize: {
        label: ["0.875rem", { lineHeight: "1", letterSpacing: "0.01em", fontWeight: "500" }],
        caption: ["0.75rem", { lineHeight: "1.4", fontWeight: "400" }],
        body: ["1rem", { lineHeight: "1.6", fontWeight: "400" }],
        "heading-lg": ["1.8rem", { lineHeight: "1.2", letterSpacing: "-0.02em", fontWeight: "700" }],
        "heading-md": ["1.5rem", { lineHeight: "1.3", fontWeight: "600" }]
      }
    }
  },
  plugins: [],
};
