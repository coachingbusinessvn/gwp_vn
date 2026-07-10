/** GoWise Partners — Tailwind config (v3)
 *  Maps every brand token to `gp-*` utilities so you can build pages with Tailwind.
 *
 *  Build step:
 *    module.exports = require('./brand/tailwind.config.js')   // or merge `theme.extend` into yours
 *
 *  Play CDN (no build) — paste into <head> before your markup:
 *    <script src="https://cdn.tailwindcss.com"></script>
 *    <script>tailwind.config = { theme: { extend: EXTEND } }</script>
 *  (copy the `extend` object below into EXTEND)
 *
 *  Fonts (always include):
 *    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet">
 */
module.exports = {
  content: ['./**/*.html'],
  theme: {
    extend: {
      colors: {
        gp: {
          navy: { 950: '#07121F', 900: '#0D1B2A', 800: '#102338', 700: '#12304C' },
          gold: { 200: '#E7D0A2', 300: '#D7B16E', 400: '#C9A668', 500: '#B98A48', 600: '#A87636' },
          ivory: '#F7F1E7',
          porcelain: '#F5F7FA',
          mist: '#D9E0E7',
          slate: '#8193A4',
          'slate-deep': '#4C6076',
          ink: '#07121F',
          'ink-soft': '#45505C',
        },
      },
      fontFamily: {
        serif: ['"Playfair Display"', 'Georgia', 'serif'],
        sans: ['Montserrat', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        eyebrow: ['12px', { lineHeight: '1', letterSpacing: '0.24em' }],
        display: ['62px', { lineHeight: '1.06', letterSpacing: '-0.01em' }],
        h2: ['44px', { lineHeight: '1.14' }],
        h3: ['27px', { lineHeight: '1.24' }],
        lead: ['18px', { lineHeight: '1.7' }],
      },
      borderRadius: { card: '16px', lg2: '20px' },
      letterSpacing: { eyebrow: '0.24em', wide2: '0.16em' },
      maxWidth: { container: '1200px' },
      boxShadow: {
        'gp-card': '0 12px 34px rgba(7,18,31,0.06)',
        'gp-float': '0 18px 44px rgba(0,0,0,0.55)',
        'gp-gold': '0 12px 30px rgba(201,166,104,0.28)',
      },
      backgroundImage: {
        'gp-gold': 'linear-gradient(180deg, #E7D0A2, #C9A668)',
        'gp-hero': 'radial-gradient(120% 90% at 78% 22%, #12304C 0%, #0D1B2A 42%, #07121F 100%)',
      },
      transitionTimingFunction: { gp: 'cubic-bezier(0.22,0.68,0.24,1)' },
      keyframes: {
        'gp-float': { '0%,100%': { transform: 'translateY(0)' }, '50%': { transform: 'translateY(-10px)' } },
        'gp-fade': { from: { opacity: '0', transform: 'translateY(14px)' }, to: { opacity: '1', transform: 'none' } },
        'gp-spin': { to: { transform: 'rotate(360deg)' } },
      },
      animation: {
        'gp-float': 'gp-float 6s ease-in-out infinite',
        'gp-fade': 'gp-fade 0.8s ease both',
        'gp-spin': 'gp-spin 44s linear infinite',
      },
    },
  },
  plugins: [],
};
