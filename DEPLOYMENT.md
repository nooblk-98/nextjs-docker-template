# Deployment Guide

This guide covers deploying your Next.js Docker application to various platforms.

## 📋 Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Security scan completed
- [ ] Environment variables configured
- [ ] SSL certificates obtained (for production)
- [ ] Database migrations ready (if applicable)
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Domain DNS configured

## 🐳 Docker Deployment

### Local Production Test

```bash
# Build and run
make deploy

# Or manually
docker build -t nextjs-app:latest .
docker-compose up -d

# Check health
curl http://localhost:3000/api/health
```

### Docker Swarm

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml nextjs-stack

# Check services
docker service ls
docker service logs nextjs-stack_nextjs

# Scale service
docker service scale nextjs-stack_nextjs=3

# Update service
docker service update --image nextjs-app:v2 nextjs-stack_nextjs

# Remove stack
docker stack rm nextjs-stack
```

## ☸️ Kubernetes Deployment

### Using Kompose

```bash
# Convert Docker Compose to Kubernetes
kompose convert -f docker-compose.yml

# Apply to cluster
kubectl apply -f .

# Check deployment
kubectl get pods
kubectl get services

# View logs
kubectl logs -f deployment/nextjs

# Scale deployment
kubectl scale deployment nextjs --replicas=3
```

### Manual Kubernetes Manifests

Create `k8s/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nextjs-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nextjs
  template:
    metadata:
      labels:
        app: nextjs
    spec:
      containers:
      - name: nextjs
        image: your-registry/nextjs-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          limits:
            cpu: "2"
            memory: "2Gi"
          requests:
            cpu: "500m"
            memory: "512Mi"
        livenessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: nextjs-service
spec:
  selector:
    app: nextjs
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
```

Deploy:

```bash
kubectl apply -f k8s/
```

## ☁️ Cloud Platform Deployments

### AWS ECS (Elastic Container Service)

#### 1. Push to ECR

```bash
# Authenticate to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.us-east-1.amazonaws.com

# Build and tag
docker build -t nextjs-app .
docker tag nextjs-app:latest \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/nextjs-app:latest

# Push
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/nextjs-app:latest
```

#### 2. Create Task Definition

```json
{
  "family": "nextjs-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "containerDefinitions": [
    {
      "name": "nextjs",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/nextjs-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
```

#### 3. Create Service

```bash
aws ecs create-service \
  --cluster my-cluster \
  --service-name nextjs-service \
  --task-definition nextjs-app \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}"
```

### Google Cloud Run

```bash
# Build and push to GCR
gcloud builds submit --tag gcr.io/PROJECT_ID/nextjs-app

# Deploy to Cloud Run
gcloud run deploy nextjs-app \
  --image gcr.io/PROJECT_ID/nextjs-app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --max-instances 10 \
  --set-env-vars NODE_ENV=production

# Get service URL
gcloud run services describe nextjs-app --platform managed --region us-central1
```

### Azure Container Instances

```bash
# Login to Azure
az login

# Create resource group
az group create --name nextjs-rg --location eastus

# Create container registry
az acr create --resource-group nextjs-rg --name nextjsregistry --sku Basic

# Build and push
az acr build --registry nextjsregistry --image nextjs-app:latest .

# Deploy container
az container create \
  --resource-group nextjs-rg \
  --name nextjs-app \
  --image nextjsregistry.azurecr.io/nextjs-app:latest \
  --cpu 2 \
  --memory 2 \
  --registry-login-server nextjsregistry.azurecr.io \
  --registry-username $(az acr credential show --name nextjsregistry --query username -o tsv) \
  --registry-password $(az acr credential show --name nextjsregistry --query passwords[0].value -o tsv) \
  --dns-name-label nextjs-app-unique \
  --ports 3000 \
  --environment-variables NODE_ENV=production

# Get FQDN
az container show --resource-group nextjs-rg --name nextjs-app --query ipAddress.fqdn
```

### DigitalOcean App Platform

```bash
# Install doctl
snap install doctl

# Authenticate
doctl auth init

# Create app spec (app.yaml)
cat > app.yaml <<EOF
name: nextjs-app
services:
- name: web
  github:
    repo: your-username/nextjs-docker-template
    branch: main
    deploy_on_push: true
  dockerfile_path: Dockerfile
  http_port: 3000
  instance_count: 2
  instance_size_slug: professional-xs
  health_check:
    http_path: /api/health
  envs:
  - key: NODE_ENV
    value: production
EOF

# Create app
doctl apps create --spec app.yaml

# Get app info
doctl apps list
```

## 🌐 VPS Deployment

### Using Docker Compose

```bash
# SSH to server
ssh user@your-server.com

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone repository
git clone https://github.com/your-username/nextjs-docker-template.git
cd nextjs-docker-template

# Setup environment
cp .env.example .env.local
nano .env.local  # Edit as needed

# Deploy
docker-compose up -d

# Setup Nginx (optional)
sudo apt install nginx
sudo nano /etc/nginx/sites-available/nextjs-app
```

Nginx config:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/nextjs-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Setup SSL with Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 🔄 CI/CD Deployment

### GitHub Actions (Automated)

The included `.github/workflows/docker-build.yml` automatically:
- Builds on push to main
- Runs security scans
- Pushes to GitHub Container Registry

To deploy automatically, add deployment step:

```yaml
- name: Deploy to production
  if: github.ref == 'refs/heads/main'
  run: |
    # SSH to server and pull latest image
    ssh user@server "cd /app && docker-compose pull && docker-compose up -d"
```

### GitLab CI/CD

Create `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

deploy:
  stage: deploy
  only:
    - main
  script:
    - ssh user@server "docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA"
    - ssh user@server "docker-compose up -d"
```

## 📊 Post-Deployment

### Verify Deployment

```bash
# Check health
curl https://your-domain.com/api/health

# Check response time
curl -w "@curl-format.txt" -o /dev/null -s https://your-domain.com

# Load test
ab -n 1000 -c 10 https://your-domain.com/
```

### Setup Monitoring

- **Uptime monitoring**: UptimeRobot, Pingdom
- **Application monitoring**: New Relic, Datadog
- **Log aggregation**: ELK Stack, Papertrail
- **Error tracking**: Sentry

### Setup Backups

```bash
# Automated backup script
cat > backup.sh <<EOF
#!/bin/bash
DATE=$(date +%Y%m%d-%H%M%S)
docker-compose exec -T nextjs tar czf - /app > backup-\$DATE.tar.gz
# Upload to S3
aws s3 cp backup-\$DATE.tar.gz s3://your-bucket/backups/
EOF

# Add to crontab
crontab -e
# Add: 0 2 * * * /path/to/backup.sh
```

## 🚨 Rollback Strategy

```bash
# Tag current version
docker tag nextjs-app:latest nextjs-app:v1.0.0

# If deployment fails, rollback
docker-compose down
docker tag nextjs-app:v1.0.0 nextjs-app:latest
docker-compose up -d
```

## 📚 Additional Resources

- [Docker Deployment Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)

---

**Happy Deploying! 🚀**
