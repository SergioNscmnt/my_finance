/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: "class",
  content: [
    "./app/views/**/*.{erb,html}",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.{js,jsx,ts,tsx}"
  ],
  theme: {
    screens: {
      sm: { max: "639px" }, // < 640
      md: { min: "641px", max: "1007px" }, // tablets
      lg: { min: "1008px", max: "1920px" }, // desktops
      xl: { min: "1921px" }, // extra-large
    },
    extend: {},
  },
  plugins: [],
};
