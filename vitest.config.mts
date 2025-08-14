import { configDefaults, defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import { resolve } from "path";

export default defineConfig({
  plugins: [react()],
  assetsInclude: ["**/*.lua", "**/*.rb", "**/*.wasm"],
  resolve: {
    alias: [{ find: "@", replacement: resolve(import.meta.dirname) }],
  },
  test: {
    setupFiles: ["./vitest.setup.tsx"],
    environment: "jsdom",
    exclude: [...configDefaults.exclude, "vendor"],
    coverage: {
      provider: "istanbul",
    },
    browser: {
      enabled: true,
      instances: [
        {
          browser: "chromium",
          provider: "playwright",
        },
      ],
    },
  },
});
