# Security Guide

This document outlines the security features and best practices implemented in this Next.js Docker template.

## 🔒 Security Features

### 1. Container Security

#### Non-Root User
The application runs as a non-root user (UID 1001) to minimize security risks.

```dockerfile
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs
USER nextjs
```

**Why?** Running as root inside containers can lead to privilege escalation attacks.

#### Read-Only Filesystem
The container's root filesystem is mounted as read-only.

```yaml
read_only: true
tmpfs:
  - /tmp:noexec,nosuid,size=100m
  - /app/.next/cache:noexec,nosuid,size=500m
```

**Why?** Prevents attackers from modifying system files or installing malware.

#### Dropped Capabilities
All Linux capabilities are dropped except essential ones.

```yaml
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

**Why?** Reduces the attack surface by removing unnecessary privileges.

#### No New Privileges
Prevents privilege escalation within the container.

```yaml
security_opt:
  - no-new-privileges:true
```

### 2. Application Security

#### Security Headers
Comprehensive security headers are configured in `next.config.js`:

- **Strict-Transport-Security**: Forces HTTPS connections
- **X-Frame-Options**: Prevents clickjacking attacks
- **X-Content-Type-Options**: Prevents MIME-type sniffing
- **X-XSS-Protection**: Enables browser XSS protection
- **Referrer-Policy**: Controls referrer information
- **Permissions-Policy**: Restricts browser features

#### Content Security Policy (CSP)
Add CSP headers to prevent XSS attacks:

```javascript
{
  key: 'Content-Security-Policy',
  value: "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
}
```

### 3. Network Security

#### Nginx Reverse Proxy
Optional Nginx configuration provides:

- **SSL/TLS Termination**: Encrypted connections
- **Rate Limiting**: DDoS protection
- **Request Filtering**: Blocks malicious requests

#### Network Isolation
Containers run in isolated Docker networks:

```yaml
networks:
  nextjs-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### 4. Resource Limits

Prevent resource exhaustion attacks:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
```

### 5. Secrets Management

#### Environment Variables
Never commit secrets to version control:

```bash
# ❌ DON'T DO THIS
DATABASE_URL=postgresql://user:password@localhost:5432/db

# ✅ DO THIS
# Use .env.local (gitignored)
# Or use Docker secrets/Kubernetes secrets
```

#### Docker Secrets
For production, use Docker secrets:

```yaml
secrets:
  db_password:
    external: true

services:
  nextjs:
    secrets:
      - db_password
```

#### Kubernetes Secrets
For Kubernetes deployments:

```bash
kubectl create secret generic app-secrets \
  --from-literal=database-url='postgresql://...'
```

## 🛡️ Security Best Practices

### 1. Regular Updates

#### Update Base Images
```bash
# Pull latest Alpine image
docker pull node:20-alpine

# Rebuild with latest base
docker build --no-cache -t nextjs-app:latest .
```

#### Update Dependencies
```bash
# Check for vulnerabilities
npm audit

# Fix vulnerabilities
npm audit fix

# Update dependencies
npm update
```

### 2. Image Scanning

#### Using Docker Scout
```bash
docker scout cves nextjs-app:latest
docker scout recommendations nextjs-app:latest
```

#### Using Trivy
```bash
trivy image nextjs-app:latest
trivy image --severity HIGH,CRITICAL nextjs-app:latest
```

#### Using Snyk
```bash
snyk container test nextjs-app:latest
snyk container monitor nextjs-app:latest
```

### 3. Secure Build Process

#### Multi-Stage Builds
Separate build and runtime environments:

```dockerfile
# Build stage - includes dev dependencies
FROM node:20-alpine AS builder
RUN npm ci

# Runtime stage - only production dependencies
FROM node:20-alpine AS runner
COPY --from=builder /app/.next/standalone ./
```

#### .dockerignore
Exclude sensitive files from build context:

```
.env*.local
.git
*.pem
*.key
node_modules
```

### 4. Runtime Security

#### Health Checks
Monitor container health:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', ...)"
```

#### Logging
Enable structured logging:

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 5. Network Security

#### HTTPS Only
Always use HTTPS in production:

```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```

#### Rate Limiting
Protect against DDoS:

```nginx
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
limit_req zone=general burst=20 nodelay;
```

## 🔍 Security Checklist

### Before Deployment

- [ ] All dependencies updated
- [ ] Security scan completed (no HIGH/CRITICAL vulnerabilities)
- [ ] Secrets stored securely (not in code)
- [ ] HTTPS enabled
- [ ] Security headers configured
- [ ] Rate limiting enabled
- [ ] Resource limits set
- [ ] Health checks working
- [ ] Logging configured
- [ ] Backups configured

### Regular Maintenance

- [ ] Weekly dependency updates
- [ ] Monthly security scans
- [ ] Quarterly security audits
- [ ] Review access logs
- [ ] Monitor resource usage
- [ ] Test disaster recovery

## 🚨 Incident Response

### If a Security Issue is Discovered

1. **Isolate**: Stop affected containers
   ```bash
   docker-compose down
   ```

2. **Investigate**: Check logs
   ```bash
   docker-compose logs > incident-logs.txt
   ```

3. **Patch**: Update vulnerable components
   ```bash
   npm audit fix
   docker build --no-cache -t nextjs-app:latest .
   ```

4. **Verify**: Scan updated image
   ```bash
   trivy image nextjs-app:latest
   ```

5. **Deploy**: Roll out patched version
   ```bash
   docker-compose up -d
   ```

6. **Monitor**: Watch for unusual activity

## 📚 Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Next.js Security Headers](https://nextjs.org/docs/advanced-features/security-headers)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [NIST Container Security](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)

## 🤝 Reporting Security Issues

If you discover a security vulnerability, please email security@example.com instead of using the issue tracker.

---

**Security is a continuous process, not a one-time setup. Stay vigilant!**
