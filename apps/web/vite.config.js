import { createLogger, defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { spawnSync } from "node:child_process";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";
import { fileURLToPath, URL } from "node:url";

const viteLogger = createLogger();
const require = createRequire(import.meta.url);
const routerPackageRoot = dirname(dirname(require.resolve("rescript-relay-router")));
const routerCliPath = join(routerPackageRoot, "cli/RescriptRelayRouterCli.bundle.mjs");

const isKnownLightningCssFsWarning = (message) =>
  message.includes('Module "fs" has been externalized for browser compatibility') &&
  message.includes("lightningcss-wasm/index.mjs");

const isRouteJsonFile = (filePath) => {
  const normalized = filePath.replaceAll("\\", "/");
  return normalized.includes("/src/routes/") && normalized.endsWith(".json");
};

const runRouterGenerate = () => {
  const result = spawnSync(
    process.execPath,
    [routerCliPath, "generate", "-scaffold-renderers"],
    { stdio: "inherit" },
  );

  if (result.status !== 0) {
    throw new Error("rescript-relay-router route generation failed");
  }
};

const vibespaceRelayRouterPlugin = () => ({
  name: "vibespace-relay-router",
  buildStart() {
    runRouterGenerate();
  },
  configureServer(server) {
    server.watcher.add("src/routes/**/*.json");
    server.watcher.on("change", (filePath) => {
      if (isRouteJsonFile(filePath)) {
        runRouterGenerate();
      }
    });
    server.watcher.on("add", (filePath) => {
      if (isRouteJsonFile(filePath)) {
        runRouterGenerate();
      }
    });
    server.watcher.on("unlink", (filePath) => {
      if (isRouteJsonFile(filePath)) {
        runRouterGenerate();
      }
    });
  },
});

export default defineConfig({
  customLogger: {
    ...viteLogger,
    warn(message, options) {
      if (!isKnownLightningCssFsWarning(message)) {
        viteLogger.warn(message, options);
      }
    },
    warnOnce(message, options) {
      if (!isKnownLightningCssFsWarning(message)) {
        viteLogger.warnOnce(message, options);
      }
    },
  },
  plugins: [
    vibespaceRelayRouterPlugin(),
    react({ include: /\.(jsx|tsx)$/ }),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
  server: {
    port: 5177,
  },
  build: {
    target: "esnext",
  },
});
