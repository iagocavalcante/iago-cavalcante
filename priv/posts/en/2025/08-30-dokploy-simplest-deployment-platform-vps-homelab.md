%{
title: "Dokploy: The Simplest Deployment Platform for Your VPS or Homelab",
author: "Iago Cavalcante",
tags: ~w(dokploy deployment vps homelab devops docker),
description: "Complete guide on how to set up and use Dokploy to simplify deployments on VPS or homelab - the open source alternative to Vercel and Netlify for your own infrastructure.",
locale: "en",
published: true
}

---

# Dokploy: The Simplest Deployment Platform for Your VPS or Homelab

Tired of complex CI/CD setups? Want the power of Vercel but with total control over your infrastructure? Dokploy is the answer you've been looking for.

I discovered Dokploy during a frustrating migration from Kubernetes to something simpler. After testing dozens of solutions, I found a platform that combines the simplicity of Heroku with the flexibility of Docker - and best of all: it's completely open source.

## What Is Dokploy?

Dokploy is a self-hosted deployment platform that transforms any VPS into a powerful deployment machine. Think Vercel or Netlify, but running on your own infrastructure, with full Docker support and native GitHub/GitLab integration.

### Why Choose Dokploy?

After years struggling with Kubernetes, Docker Swarm, and custom bash scripts, I found in Dokploy a solution that solves real problems:

- **Simplicity**: Intuitive web interface for managing deployments
- **Flexibility**: Support for any application that runs in Docker
- **Total Control**: Your infrastructure, your rules
- **Zero Lock-in**: Open source code, data on your machine
- **Economy**: No deployment costs or artificial limits

## Environment Setup: Requirements

Before we start, you'll need:

### Minimum Hardware

- **CPU**: 2 cores (4 cores recommended)
- **RAM**: 4GB (8GB recommended)
- **Storage**: 20GB free (SSD preferable)
- **Network**: Public IP with ports 80, 443 and 3000 open

### Base Software

- **OS**: Ubuntu 20.04+ (tested and recommended)
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+

## Step 1: Initial Server Configuration

First, let's prepare our server. If you're using a VPS on Hetzner, DigitalOcean, or any other provider:

### System Updates

```bash
# Connect to your server
ssh root@YOUR_IP_HERE

# Update the system
apt update && apt upgrade -y

# Install essential dependencies
apt install -y curl wget git ufw
```

### Firewall Configuration

```bash
# Configure UFW for basic security
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 3000/tcp  # Dokploy UI
ufw --force enable
```

### Docker Installation

```bash
# Install Docker using the official script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Verify installation
docker --version
docker-compose --version
```

## Step 2: Dokploy Installation

Now comes the easiest part - installing Dokploy:

```bash
# Run the official installation script
curl -sSL https://dokploy.com/install.sh | sh
```

This script will:

1. Download the Dokploy Docker image
2. Configure docker-compose.yml
3. Start all necessary services
4. Configure nginx for reverse proxy

### Verifying Installation

```bash
# Check if containers are running
docker ps

# You should see containers like:
# - dokploy
# - dokploy-postgres
# - dokploy-redis
```

## Step 3: First Access and Configuration

### Accessing the Web Interface

Open your browser and go to:

```
http://YOUR_IP:3000
```

### Initial Setup

1. **Create Admin Account**: Set email and password for the administrative user
2. **Configure DNS**: Set up your domain (optional at this moment)
3. **SSL Certificate**: Configure Let's Encrypt for automatic HTTPS

### Domain Configuration (Optional but Recommended)

If you have a domain:

```bash
# Configure DNS A record pointing to your server
# example.com -> YOUR_IP
# *.example.com -> YOUR_IP (for automatic subdomains)
```

## Step 4: Deploying Your First Application

Let's deploy an Elixir/Phoenix application to demonstrate Dokploy's power:

### 1. Preparing the Repository

Make sure your project has:

- `Dockerfile` at root
- Environment variables configured
- Correct port binding

### 2. Creating Application in Dokploy

In the web interface:

1. **Click "New Application"**
2. **Select "GitHub Repository"**
3. **Configure the repository**:
   - URL: `https://github.com/username/project`
   - Branch: `main`
   - Build Path: `.` (project root)
   - Dockerfile Path: `Dockerfile`

### 3. Environment Variables Configuration

Configure necessary variables:

```bash
# Example for Phoenix application
DATABASE_URL=postgresql://user:password@host:5432/dbname
SECRET_KEY_BASE=your_super_secure_secret_key_here
MIX_ENV=prod
PORT=4000
PHX_HOST=example.com
```

### 4. Database Configuration

Dokploy makes database creation easy:

1. **Click "New Database"**
2. **Select PostgreSQL/MySQL/MongoDB**
3. **Configure credentials**
4. **Connect to application**

### 5. Automatic Deploy

Click **"Deploy"** and watch the magic happen:

```bash
# Real-time logs will show:
# → Cloning repository...
# → Building Docker image...
# → Starting container...
# → Health check passed ✅
# → Deployment successful!
```

## Step 5: Advanced Configuration

### Automatic SSL with Let's Encrypt

```bash
# In Dokploy panel, go to Settings > SSL
# Enable "Auto SSL" and configure:
# - Email for certificates
# - Domains to certify
```

### Automatic Backup

Configure backups for data protection:

```bash
# Create backup script
#!/bin/bash
# backup-dokploy.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/dokploy"

mkdir -p $BACKUP_DIR

# Backup database
docker exec dokploy-postgres pg_dumpall -U postgres > $BACKUP_DIR/postgres_$DATE.sql

# Backup volumes
tar -czf $BACKUP_DIR/volumes_$DATE.tar.gz /var/lib/docker/volumes/

# Keep only last 7 backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

### Basic Monitoring

Configure basic alerts:

```bash
# Install htop for monitoring
apt install -y htop

# Configure logrotate for Docker logs
echo '/var/lib/docker/containers/*/*-json.log {
  daily
  missingok
  rotate 7
  compress
  notifempty
  create 644 root root
}' > /etc/logrotate.d/docker
```

## Practical Examples: Different Deploy Types

### Node.js/Express Deploy

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Python/FastAPI Deploy

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Static Site Deploy

```dockerfile
# Dockerfile
FROM nginx:alpine
COPY dist/ /usr/share/nginx/html/
EXPOSE 80
```

## Troubleshooting: Common Issues

### Build Fails: Dockerfile Not Found

```bash
# Problem: Incorrect build context
# Solution: Check "Build Path" in Dokploy
# Should point to where Dockerfile is located
```

### Application Won't Start: Port Binding

```bash
# Problem: Application not listening on correct port
# Solution: Configure PORT variable and bind to 0.0.0.0
PORT=4000
PHX_HOST=0.0.0.0  # For Phoenix
HOST=0.0.0.0      # For other apps
```

### Database Connection Issues

```bash
# Problem: App can't connect to database
# Solution: Use Docker internal hostname
DATABASE_URL=postgresql://user:pass@dokploy-postgres:5432/db
```

### SSL Certificate Problems

```bash
# Problem: Certificate doesn't generate
# Solution: Check DNS and firewall
dig example.com  # Should return server IP
```

## Dokploy vs. Alternatives Advantages

### Dokploy vs. Kubernetes

- ✅ **Simplicity**: Web interface vs. complex YAMLs
- ✅ **Resources**: Lower CPU/RAM footprint
- ✅ **Maintenance**: Automatic updates vs. cluster management
- ✅ **Learning curve**: Hours vs. weeks

### Dokploy vs. Manual Docker Compose

- ✅ **Visual UI**: Web interface vs. command line
- ✅ **Git Integration**: Automatic deploy vs. manual
- ✅ **SSL**: Automatic certificates vs. manual configuration
- ✅ **Monitoring**: Integrated dashboards vs. external tools

### Dokploy vs. Cloud Services

- ✅ **Cost**: Your server vs. per-deployment pricing
- ✅ **Control**: Full access vs. platform limitations
- ✅ **Privacy**: Local data vs. third-party
- ✅ **Customization**: Total configuration vs. limited options

## Real Use Cases

### Freelancer with Client Projects

As a freelancer, I use Dokploy to host different client projects:

- Isolation per application
- Automatic SSL for each domain
- Independent backups
- Simplified billing

**Result**: 40% higher profit margin compared to using cloud services.

### Homelab for Personal Projects

Running Dokploy on a mini PC at home:

- Side projects
- Test environments
- Client prototypes
- Learning playground

**Result**: Zero monthly costs, total control.

## Next Steps and Optimizations

### Advanced CI/CD Configuration

```yaml
# .github/workflows/deploy.yml
name: Deploy to Dokploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Dokploy Deploy
        run: |
          curl -X POST "${{ secrets.DOKPLOY_WEBHOOK_URL }}"
```

### Advanced Monitoring

```bash
# Install Prometheus + Grafana via Dokploy
# Configure dashboards for application metrics
# Setup alerts via Slack/Discord
```

### Backup Strategy

```bash
# Complete backup script for production
#!/bin/bash
# 1. Database dumps
# 2. Docker volumes backup
# 3. Upload to S3/BackBlaze
# 4. Integrity verification
```

## Useful Resources

### Documentation and Community

- [Official Documentation](https://dokploy.com/docs)
- [Discord Community](https://discord.gg/dokploy)
- [GitHub Repository](https://github.com/dokploy/dokploy)

### Templates and Examples

- [Dokploy Templates](https://github.com/dokploy/templates)
- [Community Examples](https://github.com/dokploy/examples)

## Conclusion

Dokploy completely transformed how I manage deployments. Instead of spending hours configuring complex CI/CD pipelines, I now have a platform that "just works".

The combination of Heroku's simplicity, Docker's flexibility, and total control of your own infrastructure makes Dokploy the perfect choice for developers who want to focus on what they do best: creating amazing products.

**I recommend Dokploy for:**

- Indie developers with multiple projects
- Freelancers hosting client projects
- Startups needing cost control
- Anyone wanting simplicity without giving up power

---

**Try Dokploy today!** Installation takes less than 10 minutes, and you'll wonder how you lived without this tool.

Have questions about implementation or want to share your experience? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).

_Simple deploy, complex results. That's the power of Dokploy! 🚀_
