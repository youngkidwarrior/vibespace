# Multi-stage Dockerfile for the Vibespace backend.
# Base image: Bun 1.3.5, matching the backend runtime.

FROM oven/bun:1.3.5 AS base

WORKDIR /app

# This repo uses Yarn 4 via Corepack. The Bun image does not include Node or
# Corepack, so copy the Node/Corepack pieces from the official Node image while
# keeping Bun as the runtime base.
COPY --from=node:20-bookworm-slim /usr/local/bin/node /usr/local/bin/node
COPY --from=node:20-bookworm-slim /usr/local/lib/node_modules/corepack /usr/local/lib/node_modules/corepack

ENV YARN_ENABLE_GLOBAL_CACHE=false
ENV YARN_ENABLE_MIRROR=false

RUN ln -sf ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
    && corepack enable

# ============================================================================
# Stage 1: Dependencies
# ============================================================================
FROM base AS dependencies

COPY package.json yarn.lock .yarnrc.yml ./
COPY api/graphql/package.json ./api/graphql/package.json
COPY packages/generative-ui/package.json ./packages/generative-ui/package.json
COPY packages/schema/package.json ./packages/schema/package.json
COPY apps/web/package.json ./apps/web/package.json

RUN yarn install --immutable

# ============================================================================
# Stage 2: Build
# ============================================================================
FROM base AS build

COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

RUN yarn backend:container:check

# ============================================================================
# Stage 3: Runtime
# ============================================================================
FROM base AS runtime

ENV NODE_ENV=production
ENV PORT=3000

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json /app/yarn.lock /app/.yarnrc.yml ./
COPY --from=build /app/api ./api
COPY --from=build /app/apps ./apps
COPY --from=build /app/packages ./packages
COPY --from=build /app/db ./db

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD bun -e "fetch('http://localhost:3000/health').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))" || exit 1

CMD ["bun", "api/graphql/src/BackendServer.res.js"]
