# ============================================
# Multi-Stage Next.js Dockerfile
# Optimized for Minimal Size & Security
# ============================================

# Node.js version
ARG NODE_VERSION=21

# ============================================
# Stage 1: Dependencies
# Install dependencies needed for production
# ============================================
FROM node:${NODE_VERSION}-alpine AS deps

# Install security updates and required packages (including git for Next.js build)
RUN apk add --no-cache libc6-compat git

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install all dependencies (use npm install for better CI/CD compatibility)
RUN npm install && \
    npm cache clean --force

# ============================================
# Stage 2: Builder
# Build the Next.js application
# ============================================
FROM node:${NODE_VERSION}-alpine AS builder

# Install git for build metadata
RUN apk add --no-cache libc6-compat git

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application source
COPY . .

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build the Next.js application (standalone output)
RUN npm run build

# ============================================
# Stage 3: Runner (Production)
# Minimal runtime image with security hardening
# ============================================
FROM node:${NODE_VERSION}-alpine AS runner

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

WORKDIR /app

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Set production environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Copy the standalone output
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the standalone server (much smaller than full node_modules)
CMD ["node", "server.js"]
