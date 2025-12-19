<div align="center">
  <img src="./images/logo.png" width="360" alt="Next.js-docker logo" />

# Next.js Docker Template

**Production-ready Next.js Docker template with multi-stage builds, security hardening, and performance optimizations.**

[![CI/CD](https://github.com/nooblk-98/php-nginx-docker-template/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/nooblk-98/php-nginx-docker-template/actions/workflows/build-and-push.yml)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Security](https://img.shields.io/badge/Security-Hardened-green)](#security-features)
[![Next.js](https://img.shields.io/badge/Next.js-14-000000?logo=next.js&logoColor=white)](https://nextjs.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/nooblk-98/php-nginx-docker-template)](https://github.com/nooblk-98/php-nginx-docker-template/commits/main)
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](https://github.com/nooblk-98/php-nginx-docker-template/blob/main/CONTRIBUTING.md)

</div>

##  Features

### Security First
- **Non-root user** (UID 1001) - Prevents privilege escalation
- **Read-only filesystem** - Blocks malware installation
- **Dropped Linux capabilities** - Minimal permissions
- **Security headers** - HSTS, CSP, X-Frame-Options, X-XSS-Protection
- **SSL/TLS ready** - Nginx reverse proxy with HTTPS
- **Rate limiting** - DDoS protection (10 req/s)
- **No new privileges** - Prevents container breakout

### Performance Optimized
- **Multi-stage Docker build** - 87% smaller images (~150MB vs 1.2GB)
- **Standalone Next.js output** - Minimal runtime dependencies
- **Layer caching** - Faster rebuilds (dependencies cached separately)
- **Alpine Linux** - Lightweight base (~5MB vs ~200MB)
- **SWC minification** - Faster builds than Babel
- **Gzip compression** - Reduced bandwidth usage
- **Static asset caching** - 1-year cache for immutable files

### Developer Friendly
- **Hot reload** - Development mode with volume mounts
- **TypeScript** - Full type safety
- **Tailwind CSS** - Utility-first styling
- **ESLint** - Code quality
- **Health check endpoint** - `/api/health`
- *Makefile commands** - Convenient shortcuts
- **CI/CD ready** - GitHub Actions workflow included

## 🚀 Quick Start

### Use with your own code 

```bash
# Download Dockerfile (prod)
wget https://raw.githubusercontent.com/nooblk-98/nextjs-docker-template/refs/heads/main/Dockerfile
```
```bash
# Download Docker Compose  (prod)
wget https://raw.githubusercontent.com/nooblk-98/nextjs-docker-template/refs/heads/main/docker-compose.yml
```

### Use with your own code 

```bash
# Download Dockerfile (dev)
wget https://raw.githubusercontent.com/nooblk-98/nextjs-docker-template/refs/heads/main/Dockerfile.dev
```bash
# Download Docker Compose  (dev)
wget https://raw.githubusercontent.com/nooblk-98/nextjs-docker-template/refs/heads/main/docker-compose.dev.yml
```


### Docker Development (Hot Reload)

```bash
docker-compose -f docker-compose.dev.yml up
```

### Production Build

```bash
docker-compose up -d
```

## 💻 Usage

### NPM Scripts

```bash
# Docker shortcuts
npm run docker:build                  # Build production image
npm run docker:build:dev              # Build development image
npm run docker:run                    # Run production container
npm run docker:compose:up             # Start with compose
npm run docker:compose:down           # Stop compose
npm run docker:compose:dev            # Development mode
npm run docker:compose:logs           # View logs
```

## 🐳 Docker Commands

### Production

```bash
# Build production image
docker build -t nextjs-app:latest .

# Run production container
docker run -p 3000:3000 nextjs-app:latest

# Using Docker Compose
docker-compose up -d                  # Start in background
docker-compose down                   # Stop and remove
docker-compose logs -f                # Follow logs
docker-compose ps                     # Show status
docker-compose restart                # Restart services
```

### Development

```bash
# Build development image
docker build -f Dockerfile.dev -t nextjs-app:dev .

# Run development container with hot reload
docker-compose -f docker-compose.dev.yml up

# Stop development containers
docker-compose -f docker-compose.dev.yml down
```

### Useful Commands

```bash
# View container logs
docker logs -f nextjs-production

# Execute command in container
docker exec -it nextjs-production sh

# Check container health
docker inspect --format='{{.State.Health.Status}}' nextjs-production

# View resource usage
docker stats nextjs-production

# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune -a
```

## ⚙️ Configuration

### Environment Variables

1. Copy the example file:
```bash
cp .env.example .env.local
```

2. Edit `.env.local` with your values:
```env
NODE_ENV=production
PORT=3000
NEXT_TELEMETRY_DISABLED=1

# Add your custom variables
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
API_KEY=your-api-key-here
NEXT_PUBLIC_API_URL=https://api.example.com
```

3. Update `next.config.js` if needed:
```javascript
env: {
  DATABASE_URL: process.env.DATABASE_URL,
  API_KEY: process.env.API_KEY,
}
```

### Node.js Version

The Node.js version is configurable via build arguments:

**Method 1: Docker Compose (Recommended)**

Edit `docker-compose.yml` or `docker-compose.dev.yml`:
```yaml
build:
  args:
    NODE_VERSION: 20  # Change to 18, 20, 21, etc.
```

**Method 2: Docker Build Command**

```bash
# Build with specific Node.js version
docker build --build-arg NODE_VERSION=18 -t nextjs-app:latest .

# Or use Node.js 21
docker build --build-arg NODE_VERSION=21 -t nextjs-app:latest .
```

**Method 3: Environment Variable**

```bash
# Set environment variable
export NODE_VERSION=18

# Build
docker-compose build
```

### SSL/TLS Configuration

For development, generate self-signed certificates:

```bash
# Linux/Mac
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Windows (PowerShell)
# Use start.bat option 4 to auto-generate
```

For production, use Let's Encrypt or your certificate authority.

## 🔐 Security Features

### Container Security

#### Non-Root User
```dockerfile
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs
USER nextjs
```

#### Read-Only Filesystem
```yaml
read_only: true
tmpfs:
  - /tmp:noexec,nosuid,size=100m
  - /app/.next/cache:noexec,nosuid,size=500m
```

#### Dropped Capabilities
```yaml
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

### Application Security

Security headers configured in `next.config.js`:

- **Strict-Transport-Security**: Forces HTTPS
- **X-Frame-Options**: Prevents clickjacking
- **X-Content-Type-Options**: Prevents MIME sniffing
- **X-XSS-Protection**: Browser XSS protection
- **Referrer-Policy**: Controls referrer information
- **Permissions-Policy**: Restricts browser features

### Network Security

Nginx provides:
- SSL/TLS termination
- Rate limiting (10 req/s)
- Gzip compression
- Static asset caching
- Security headers

## 🌐 Deployment

### Docker Swarm

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml nextjs-stack

# Check services
docker service ls

# Scale service
docker service scale nextjs-stack_nextjs=3

# Remove stack
docker stack rm nextjs-stack
```

### Multi-Stage Docker Build

```
Stage 1: Dependencies
  ↓ (Copy node_modules)
Stage 2: Builder
  ↓ (Copy .next/standalone)
Stage 3: Runner (Final Image ~150MB)
```

### Request Flow

```
Client Request
  ↓
Nginx (Port 443)
  ├─→ SSL Termination
  ├─→ Rate Limit Check
  ├─→ Security Headers
  └─→ Gzip Compression
  ↓
Next.js (Port 3000)
  ├─→ Static Files → Serve from .next/static
  ├─→ API Route → Execute handler
  ├─→ SSR Page → Render on server
  └─→ SSG Page → Serve pre-rendered HTML
  ↓
Response to Client
```

## 🐛 Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs nextjs-production

# Inspect container
docker inspect nextjs-production

# Check health status
docker inspect --format='{{.State.Health.Status}}' nextjs-production
```

### Permission Issues

```bash
# Ensure files are accessible to UID 1001
chown -R 1001:1001 /path/to/files
```

### Build Failures

```bash
# Clear Docker cache
docker builder prune -a

# Rebuild without cache
docker build --no-cache -t nextjs-app:latest .
```

### Health Check Fails

```bash
# Test health endpoint
curl http://localhost:3000/api/health

# Check from inside container
docker exec nextjs-production curl http://localhost:3000/api/health
```

### Hot Reload Not Working

```bash
# Ensure volume mounts are correct in docker-compose.dev.yml
volumes:
  - .:/app
  - /app/node_modules
  - /app/.next

# Set polling environment variables
environment:
  - WATCHPACK_POLLING=true
  - CHOKIDAR_USEPOLLING=true
```

## 🤝 Contributing

Contributions are welcome! 

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

- [Next.js](https://nextjs.org/) - The React Framework
- [Docker](https://www.docker.com/) - Containerization Platform
- [Alpine Linux](https://alpinelinux.org/) - Lightweight Linux Distribution
- [Nginx](https://nginx.org/) - High-Performance Web Server


## ⭐ Show Your Support

If this template helped you, please give it a star! ⭐

---

<div align="center">

**Made with ❤️ by NoobLK**

[⬆ Back to top](#php-nginx-docker-template)

</div>