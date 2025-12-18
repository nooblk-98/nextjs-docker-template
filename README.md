# Next.js Docker Template

A production-ready, security-hardened, and performance-optimized Docker template for Next.js applications.

## 🚀 Features

### Performance Optimizations
- ✅ **Multi-stage Docker build** - Minimal production image size
- ✅ **Standalone output** - Next.js optimized for containers
- ✅ **Layer caching** - Faster rebuilds with optimized layer ordering
- ✅ **Alpine Linux** - Lightweight base image (~50MB)
- ✅ **SWC Minification** - Faster builds and smaller bundles

### Security Hardening
- ✅ **Non-root user** - Runs as unprivileged user (UID 1001)
- ✅ **Read-only filesystem** - Container runs with read-only root filesystem
- ✅ **No new privileges** - Prevents privilege escalation
- ✅ **Dropped capabilities** - Minimal Linux capabilities
- ✅ **Security headers** - HSTS, CSP, X-Frame-Options, etc.
- ✅ **Nginx reverse proxy** - Optional SSL termination and rate limiting

### DevOps Ready
- ✅ **Health checks** - Built-in container health monitoring
- ✅ **Resource limits** - CPU and memory constraints
- ✅ **Logging** - Structured logging with rotation
- ✅ **Hot reload** - Development mode with volume mounts
- ✅ **Environment variables** - Flexible configuration

## 📋 Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Node.js 18+ (for local development)

## 🏗️ Project Structure

```
nextjs-docker-template/
├── src/
│   └── app/
│       ├── api/
│       │   └── health/
│       │       └── route.ts          # Health check endpoint
│       ├── globals.css               # Global styles
│       ├── layout.tsx                # Root layout
│       └── page.tsx                  # Home page
├── nginx/
│   └── nginx.conf                    # Nginx reverse proxy config
├── Dockerfile                        # Production Dockerfile
├── Dockerfile.dev                    # Development Dockerfile
├── docker-compose.yml                # Production compose
├── docker-compose.dev.yml            # Development compose
├── .dockerignore                     # Docker build exclusions
├── next.config.js                    # Next.js configuration
├── package.json                      # Dependencies & scripts
└── .env.example                      # Environment variables template
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd nextjs-docker-template
cp .env.example .env.local
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Development Mode

#### Option A: Local Development (without Docker)
```bash
npm run dev
```

#### Option B: Docker Development (with hot reload)
```bash
npm run docker:compose:dev
```

Visit [http://localhost:3000](http://localhost:3000)

### 4. Production Build

#### Build Docker Image
```bash
npm run docker:build
```

#### Run with Docker Compose
```bash
npm run docker:compose:up
```

#### View Logs
```bash
npm run docker:compose:logs
```

## 🐳 Docker Commands

### Production

```bash
# Build production image
docker build -t nextjs-app:latest .

# Run production container
docker run -p 3000:3000 nextjs-app:latest

# Using Docker Compose
docker-compose up -d
docker-compose down
docker-compose logs -f
```

### Development

```bash
# Build development image
docker build -f Dockerfile.dev -t nextjs-app:dev .

# Run development container with hot reload
docker-compose -f docker-compose.dev.yml up
```

## 🔧 Configuration

### Environment Variables

Create a `.env.local` file (copy from `.env.example`):

```env
NODE_ENV=production
PORT=3000
NEXT_TELEMETRY_DISABLED=1

# Add your custom variables
# DATABASE_URL=postgresql://...
# API_KEY=your-api-key
```

### Next.js Configuration

Edit `next.config.js` to customize:
- Image domains
- Security headers
- Redirects/rewrites
- Environment variables

### Docker Compose Configuration

#### Resource Limits

Edit `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 512M
```

#### Port Mapping

```yaml
ports:
  - "3000:3000"  # Change host port as needed
```

## 🔒 Security Features

### 1. Multi-Stage Build
- Separates build dependencies from runtime
- Reduces attack surface
- Smaller final image

### 2. Non-Root User
```dockerfile
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs
USER nextjs
```

### 3. Read-Only Filesystem
```yaml
read_only: true
tmpfs:
  - /tmp:noexec,nosuid,size=100m
```

### 4. Security Headers

Configured in `next.config.js`:
- Strict-Transport-Security
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection
- Referrer-Policy
- Permissions-Policy

### 5. Nginx Reverse Proxy

Optional Nginx configuration includes:
- SSL/TLS termination
- Rate limiting
- Gzip compression
- Static asset caching
- Security headers

## 📊 Health Checks

### Docker Health Check

Built into Dockerfile:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', ...)"
```

### Health Endpoint

Available at `/api/health`:

```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 123.456,
  "environment": "production"
}
```

## 🎯 Performance Optimizations

### 1. Standalone Output
```javascript
// next.config.js
output: 'standalone'
```

### 2. Layer Caching
Dependencies are installed in a separate layer for faster rebuilds.

### 3. Compression
- Nginx gzip compression
- Next.js built-in compression

### 4. Static Asset Caching
```nginx
location /_next/static {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 📦 Building for Production

### Standard Build

```bash
# Build image
docker build -t nextjs-app:latest .

# Tag for registry
docker tag nextjs-app:latest your-registry/nextjs-app:v1.0.0

# Push to registry
docker push your-registry/nextjs-app:v1.0.0
```

### Multi-Platform Build

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t your-registry/nextjs-app:latest \
  --push .
```

## 🚀 Deployment

### Docker Swarm

```bash
docker stack deploy -c docker-compose.yml nextjs-stack
```

### Kubernetes

Convert Docker Compose to Kubernetes:

```bash
kompose convert -f docker-compose.yml
kubectl apply -f .
```

### Cloud Platforms

#### AWS ECS
1. Push image to ECR
2. Create task definition
3. Create ECS service

#### Google Cloud Run
```bash
gcloud run deploy nextjs-app \
  --image gcr.io/project-id/nextjs-app \
  --platform managed
```

#### Azure Container Instances
```bash
az container create \
  --resource-group myResourceGroup \
  --name nextjs-app \
  --image your-registry/nextjs-app:latest
```

## 🔍 Monitoring

### Container Logs

```bash
# Docker
docker logs -f <container-id>

# Docker Compose
docker-compose logs -f nextjs

# Follow specific service
docker-compose logs -f --tail=100 nextjs
```

### Resource Usage

```bash
# Docker stats
docker stats

# Specific container
docker stats nextjs-production
```

## 🛠️ Troubleshooting

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

Ensure files are accessible to UID 1001:
```bash
chown -R 1001:1001 /path/to/files
```

### Build Failures

```bash
# Clear Docker cache
docker builder prune -a

# Rebuild without cache
docker build --no-cache -t nextjs-app:latest .
```

## 📝 Best Practices

1. **Use .dockerignore** - Exclude unnecessary files from build context
2. **Multi-stage builds** - Keep production images minimal
3. **Layer caching** - Order Dockerfile commands for optimal caching
4. **Security scanning** - Scan images for vulnerabilities
5. **Health checks** - Always implement health endpoints
6. **Resource limits** - Set appropriate CPU/memory limits
7. **Logging** - Use structured logging with rotation
8. **Secrets management** - Never commit secrets, use environment variables

## 🔐 Security Scanning

### Scan Docker Image

```bash
# Using Docker Scout
docker scout cves nextjs-app:latest

# Using Trivy
trivy image nextjs-app:latest

# Using Snyk
snyk container test nextjs-app:latest
```

## 📚 Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [Docker Security](https://docs.docker.com/engine/security/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Next.js team for the amazing framework
- Docker community for best practices
- Security researchers for hardening guidelines

---

**Made with ❤️ for the Next.js community**