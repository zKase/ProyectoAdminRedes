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
        
        "outline": "rgb(var(--outline) / <alpha-value>)",
        "outline-variant": "rgb(var(--outline-variant) / <alpha-value>)",
        
        "error": "rgb(var(--error) / <alpha-value>)",
        "on-error": "rgb(var(--on-error) / <alpha-value>)",
        "error-container": "rgb(var(--error-container) / <alpha-value>)",
        "on-error-container": "rgb(var(--on-error-container) / <alpha-value>)",
        
        "success": "rgb(var(--success) / <alpha-value>)",
        "on-success": "rgb(var(--on-success) / <alpha-value>)",
        
        "accent": "rgb(var(--accent) / <alpha-value>)",
      },
      boxShadow: {
        'glass': '0 4px 30px rgba(var(--glass-shadow), 0.5)',
        'neon': '0 0 10px rgba(var(--neon-glow), 0.3), 0 0 20px rgba(var(--neon-glow), 0.1)',
        'elevated': '0 10px 40px -10px rgba(var(--glass-shadow), 0.5)'
      },
      borderRadius: {
        DEFAULT: "0.5rem",
        lg: "0.75rem",
        xl: "1rem",
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
        label: ["Outfit", "sans-serif"],
        caption: ["Outfit", "sans-serif"],
        body: ["Inter", "sans-serif"],
        "heading-lg": ["Outfit", "sans-serif"],
        "heading-md": ["Outfit", "sans-serif"]
      },
      fontSize: {
        label: ["0.875rem", { lineHeight: "1", letterSpacing: "0.02em", fontWeight: "600" }],
        caption: ["0.75rem", { lineHeight: "1.4", fontWeight: "500" }],
        body: ["1rem", { lineHeight: "1.6", fontWeight: "400" }],
        "heading-lg": ["2.2rem", { lineHeight: "1.1", letterSpacing: "-0.03em", fontWeight: "800" }],
        "heading-md": ["1.5rem", { lineHeight: "1.2", letterSpacing: "-0.02em", fontWeight: "700" }]
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
