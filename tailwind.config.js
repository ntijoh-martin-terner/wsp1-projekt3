/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./views/**/*.erb", "./components/**/*.erb", "./node_modules/flowbite/**/*.js", "./views/*.erb"],
  theme: {
    extend: {},
  },
  darkMode: 'class',
  plugins: [
    require('flowbite/plugin')
  ]
}

