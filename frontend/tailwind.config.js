/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts,tsx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "background": "rgb(var(--background) / <alpha-value>)",
        "surface": "rgb(var(--surface) / <alpha-value>)",
        "surface-dim": "rgb(var(--surface-dim) / <alpha-value>)",
        "surface-bright": "rgb(var(--surface-bright) / <alpha-value>)",
        "surface-container-lowest": "rgb(var(--surface-container-lowest) / <alpha-value>)",
        "surface-container-low": "rgb(var(--surface-container-low) / <alpha-value>)",
        "surface-container": "rgb(var(--surface-container) / <alpha-value>)",
        "surface-container-high": "rgb(var(--surface-container-high) / <alpha-value>)",
        "surface-container-highest": "rgb(var(--surface-container-highest) / <alpha-value>)",

        "on-background": "rgb(var(--on-background) / <alpha-value>)",
        "on-surface": "rgb(var(--on-surface) / <alpha-value>)",
        "on-surface-variant": "rgb(var(--on-surface-variant) / <alpha-value>)",

        "primary": "rgb(var(--primary) / <alpha-value>)",
        "on-primary": "rgb(var(--on-primary) / <alpha-value>)",
        "primary-container": "rgb(var(--primary-container) / <alpha-value>)",
        "on-primary-container": "rgb(var(--on-primary-container) / <alpha-value>)",
        "primary-hover": "rgb(var(--primary-hover) / <alpha-value>)",

        "secondary": "rgb(var(--secondary) / <alpha-value>)",
        "on-secondary": "rgb(var(--on-secondary) / <alpha-value>)",
        "secondary-container": "rgb(var(--secondary-container) / <alpha-value>)",
        "on-secondary-container": "rgb(var(--on-secondary-container) / <alpha-value>)",

        "tertiary": "rgb(var(--tertiary) / <alpha-value>)",
        "on-tertiary": "rgb(var(--on-tertiary) / <alpha-value>)",
        "tertiary-container": "rgb(var(--tertiary-container) / <alpha-value>)",
        "on-tertiary-container": "rgb(var(--on-tertiary-container) / <alpha-value>)",

        "outline": "rgb(var(--outline) / <alpha-value>)",
        "outline-variant": "rgb(var(--outline-variant) / <alpha-value>)",

        "error": "rgb(var(--error) / <alpha-value>)",
        "on-error": "rgb(var(--on-error) / <alpha-value>)",
        "error-container": "rgb(var(--error-container) / <alpha-value>)",
        "on-error-container": "rgb(var(--on-error-container) / <alpha-value>)",

        "success": "rgb(var(--success) / <alpha-value>)",
        "on-success": "rgb(var(--on-success) / <alpha-value>)",

        "accent": "rgb(var(--accent) / <alpha-value>)",
        "inverse-surface": "rgb(var(--inverse-surface) / <alpha-value>)",
        "inverse-on-surface": "rgb(var(--inverse-on-surface) / <alpha-value>)",
      },
      boxShadow: {
        'glass': '0 4px 30px rgba(var(--glass-shadow), 0.08)',
        'neon': '0 0 10px rgba(var(--neon-glow), 0.15), 0 0 20px rgba(var(--neon-glow), 0.05)',
        'elevated': '0 10px 40px -10px rgba(var(--glass-shadow), 0.12)',
        'soft': '0 2px 8px rgba(var(--glass-shadow), 0.06)',
        'card': '0 1px 3px rgba(var(--glass-shadow), 0.04), 0 1px 2px rgba(var(--glass-shadow), 0.06)',
      },
      borderRadius: {
        sm: "0.25rem",
        DEFAULT: "0.5rem",
        md: "0.75rem",
        lg: "1rem",
        xl: "1.5rem",
        full: "9999px"
      },
      spacing: {
        xs: "4px",
        sm: "8px",
        md: "16px",
        lg: "24px",
        xl: "32px",
        "2xl": "48px",
        gutter: "24px",
      },
      fontFamily: {
        label: ["Inter", "sans-serif"],
        caption: ["Inter", "sans-serif"],
        body: ["Inter", "sans-serif"],
        "heading-lg": ["Inter", "sans-serif"],
        "heading-md": ["Inter", "sans-serif"],
        "heading-sm": ["Inter", "sans-serif"],
      },
      fontSize: {
        label: ["0.875rem", { lineHeight: "1.25rem", letterSpacing: "0.01em", fontWeight: "600" }],
        caption: ["0.75rem", { lineHeight: "1rem", letterSpacing: "0.02em", fontWeight: "600" }],
        body: ["1rem", { lineHeight: "1.5rem", fontWeight: "400" }],
        "heading-lg": ["2rem", { lineHeight: "2.5rem", letterSpacing: "-0.02em", fontWeight: "700" }],
        "heading-md": ["1.5rem", { lineHeight: "2rem", letterSpacing: "-0.01em", fontWeight: "600" }],
        "heading-sm": ["1.25rem", { lineHeight: "1.75rem", fontWeight: "600" }],
        "body-sm": ["0.875rem", { lineHeight: "1.25rem", fontWeight: "400" }],
      },
      animation: {
        'fade-in': 'fadeIn 0.4s cubic-bezier(0.16, 1, 0.3, 1)',
        'slide-up': 'slideUp 0.5s cubic-bezier(0.16, 1, 0.3, 1)',
        'spin-slow': 'spin 3s linear infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        }
      }
    }
  },
  plugins: [],
};
