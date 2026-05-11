/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts,tsx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        // Dark Mode Elegant with Electric Blue accents
        "background": "#0a0a0c",
        "surface": "#121217",
        "surface-container-lowest": "#16161c",
        "surface-container-low": "#1c1c24",
        "surface-container": "#22222d",
        "surface-container-high": "#2b2b36",
        "surface-container-highest": "#353542",
        
        "on-background": "#f0f2f5",
        "on-surface": "#e0e2e8",
        "on-surface-variant": "#a1a5b5",
        
        "primary": "#00f0ff", // Electric Blue
        "on-primary": "#000000",
        "primary-container": "rgba(0, 240, 255, 0.15)",
        "on-primary-container": "#b3fbff",
        "primary-hover": "#00d5e3",
        
        "secondary": "#0a84ff",
        "on-secondary": "#ffffff",
        "secondary-container": "rgba(10, 132, 255, 0.15)",
        "on-secondary-container": "#bce0ff",
        
        "outline": "#3d4154",
        "outline-variant": "#2b2d3b",
        
        "error": "#ff453a",
        "on-error": "#ffffff",
        "error-container": "rgba(255, 69, 58, 0.15)",
        "on-error-container": "#ffd1ce",
        
        "success": "#32d74b",
        "on-success": "#ffffff",
        
        "accent": "#bf5af2",
      },
      boxShadow: {
        'glass': '0 4px 30px rgba(0, 0, 0, 0.5)',
        'neon': '0 0 10px rgba(0, 240, 255, 0.3), 0 0 20px rgba(0, 240, 255, 0.1)',
        'elevated': '0 10px 40px -10px rgba(0,0,0,0.5)'
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
