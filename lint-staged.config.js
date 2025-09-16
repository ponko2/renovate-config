/**
 * @filename: lint-staged.config.js
 * @type {import('lint-staged').Configuration}
 */
export default {
  "*.{cjs,css,js,json,jsx,mjs,ts,tsx,yaml,yml}": "prettier --write",
  "default.json": "renovate-config-validator --strict",
};
