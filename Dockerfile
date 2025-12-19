# ============================================
# Multi-Stage Next.js Dockerfile
# Optimized for Performance & Security
# ============================================

# Node.js version
ARG NODE_VERSION=20

# ============================================
# Stage 1: Dependencies
# Install only production dependencies
# ============================================
FROM node:${NODE_VERSION}-alpine AS deps

# Install security updates and required packages
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies with clean install for reproducible builds
RUN npm ci --only=production && \
    npm cache clean --force

# ============================================
# Stage 2: Builder
# Build the Next.js application
# ============================================
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-alpine AS builder

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application source
COPY . .

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Install all dependencies (including devDependencies) for build
RUN npm ci && \
    npm cache clean --force

# Ensure public directory exists
RUN mkdir -p public

# Build the Next.js application with standalone output
RUN npm run build

# ============================================
# Stage 3: Runner (Production)
# Minimal runtime image with security hardening
# ============================================
ARG NODE_VERSION=20
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

# Copy only necessary files from builder
# Public folder (Next.js creates this during build)
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "server.js"]
