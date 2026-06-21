# ========================================
# Multi-stage Dockerfile for Next.js App
# Supports: production, staging, dev, builder
# ========================================

# ========================================
# Stage 1: Base image with dependencies
# ========================================
FROM node:22-alpine AS base

# Install libc6-compat for native binaries
RUN apk add --no-cache libc6-compat

WORKDIR /app

# ========================================
# Stage 2: Development environment
# ========================================
FROM base AS dev

# Install development dependencies
COPY package.json package-lock.json* ./
RUN npm ci

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Start development server
CMD ["npm", "run", "dev"]

# ========================================
# Stage 3: Dependencies installation
# ========================================
FROM base AS deps

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci && npm cache clean --force

# ========================================
# Stage 4: Builder for staging/release
# ========================================
FROM base AS builder

WORKDIR /app

# Copy dependencies
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
COPY . .

# Disable Next.js telemetry
ENV NEXT_TELEMETRY_DISABLED=1

# Build application
RUN npm run build

# ========================================
# Stage 5: Production runner
# ========================================
FROM base AS runner

WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME="0.0.0.0"

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Set ownership
RUN mkdir .next && chown nextjs:nodejs .next

# Copy built application
RUN mkdir -p ./public
COPY --from=builder --chown=nextjs:nodejs /app/public ./public/
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]

# ========================================
# Health check for production
# ========================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1