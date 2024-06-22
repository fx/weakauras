import { configDefaults, defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import { resolve } from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: [{ find: "@", replacement: resolve(__dirname) }],
  },
  test: {
    environment: "jsdom",
    exclude: [...configDefaults.exclude, "vendor"],
    coverage: {
      provider: "istanbul",
    },
    browser: {
      enabled: true,
      provider: "playwright",
      name: "chromium",
    },
  },
});
