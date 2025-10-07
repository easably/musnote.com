# Deployment Guide

## Docker Deployment

### Prerequisites
- Docker installed locally
- GitHub account with access to GitHub Container Registry
- DigitalOcean account (for deployment)

### Building Docker Image Locally

```bash
# Build the image
docker build -t musnote .

# Run locally for testing
docker run -p 8080:80 musnote

# Visit http://localhost:8080 in your browser
```

### GitHub Actions Automatic Build

The repository is configured with GitHub Actions to automatically:
1. Build Docker image on every push to `main` branch
2. Push the image to GitHub Container Registry (ghcr.io)
3. Tag the image appropriately

The workflow runs automatically when you push to the repository.

### Accessing the Docker Image

After GitHub Actions builds the image, it will be available at:
```
ghcr.io/<your-github-username>/musnote.com:latest
```

To make the image public:
1. Go to your GitHub profile
2. Click on "Packages"
3. Find "musnote.com"
4. Click "Package settings"
5. Scroll to "Danger Zone"
6. Click "Change visibility" and set to "Public"

### Deploying to DigitalOcean

#### Option 1: Using DigitalOcean App Platform

1. Log in to DigitalOcean
2. Create a new App
3. Choose "Docker Hub or Container Registry"
4. Enter: `ghcr.io/<your-github-username>/musnote.com:latest`
5. If private, add GitHub Container Registry credentials:
   - Registry: `ghcr.io`
   - Username: Your GitHub username
   - Password: GitHub Personal Access Token with `read:packages` scope
6. Deploy

#### Option 2: Using DigitalOcean Droplet

1. Create a Droplet with Docker pre-installed
2. SSH into the droplet
3. Log in to GitHub Container Registry:
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u <your-github-username> --password-stdin
   ```
4. Pull and run the image:
   ```bash
   docker pull ghcr.io/<your-github-username>/musnote.com:latest
   docker run -d -p 80:80 --name musnote --restart unless-stopped \
     ghcr.io/<your-github-username>/musnote.com:latest
   ```

#### Option 3: Automated Deployment with GitHub Actions

You can extend the workflow to automatically deploy to DigitalOcean by adding deployment steps:

```yaml
# Add to .github/workflows/docker-build.yml after build step
- name: Deploy to DigitalOcean
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.DO_HOST }}
    username: ${{ secrets.DO_USERNAME }}
    key: ${{ secrets.DO_SSH_KEY }}
    script: |
      docker pull ghcr.io/${{ github.repository }}:latest
      docker stop musnote || true
      docker rm musnote || true
      docker run -d -p 80:80 --name musnote --restart unless-stopped \
        ghcr.io/${{ github.repository }}:latest
```

Required GitHub Secrets:
- `DO_HOST`: Your droplet IP address
- `DO_USERNAME`: SSH username (usually `root`)
- `DO_SSH_KEY`: Your SSH private key

### Updating the Deployment

To update the deployment:
1. Push changes to the `main` branch
2. GitHub Actions will automatically build and push a new image
3. Pull the latest image on your server:
   ```bash
   docker pull ghcr.io/<your-github-username>/musnote.com:latest
   docker stop musnote
   docker rm musnote
   docker run -d -p 80:80 --name musnote --restart unless-stopped \
     ghcr.io/<your-github-username>/musnote.com:latest
   ```

### Health Check

The container includes a health check. To verify:
```bash
docker ps
# Look for "healthy" status
```

### Viewing Logs

```bash
docker logs musnote
docker logs -f musnote  # Follow logs
```

### Stopping the Container

```bash
docker stop musnote
docker rm musnote
```

## SSL/HTTPS Setup

For production, you should add SSL/HTTPS. Options:

1. **Using DigitalOcean Load Balancer** (recommended for App Platform)
   - Automatically provides SSL certificates

2. **Using Let's Encrypt with Nginx**
   - Add Certbot to your Dockerfile
   - Configure nginx for SSL

3. **Using Cloudflare**
   - Point your domain to Cloudflare
   - Enable SSL in Cloudflare
   - Point Cloudflare to your droplet IP

## Environment Variables

The current setup doesn't require environment variables, but if you need to add them:

```bash
docker run -d -p 80:80 \
  -e VARIABLE_NAME=value \
  --name musnote \
  ghcr.io/<your-github-username>/musnote.com:latest
```

## Monitoring

Consider setting up monitoring:
- DigitalOcean Monitoring
- Docker stats: `docker stats musnote`
- Health checks: `curl http://your-droplet-ip/`

