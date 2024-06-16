import { configDefaults, defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    exclude: [...configDefaults.exclude, "vendor"],
    browser: {
      enabled: true,
      provider: "playwright",
      name: "chromium",
    },
  },
});
