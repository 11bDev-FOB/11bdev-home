# Docker Deployment Guide for 11bDev

This guide explains how to deploy the 11bDev application using Docker with Caddy as the reverse proxy.

## Architecture

The application runs with the following containers:

- **app**: Rails application (with embedded SQLite database)
- **caddy**: Caddy web server for reverse proxy, SSL/TLS, and HTTP/3

## Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.0+
- Domain name pointing to your server (for SSL)

## Environment Variables

Create a `.env` file in the project root:

```bash
# Required
RAILS_MASTER_KEY=your_master_key_from_config_master_key

# Optional - Admin Authentication
ADMIN_USERNAME=your_admin_username
ADMIN_PASSWORD=your_secure_password

# Optional - GitHub Integration
GITHUB_TOKEN=your_github_token
```

## Quick Start

### 1. Build and Start

```bash
# Build the application image
docker compose build

# Start all services
docker compose up -d

# Check logs
docker compose logs -f
```

### 2. Initialize Database

```bash
# Run migrations
docker compose exec app bin/rails db:migrate

# Seed database (if needed)
docker compose exec app bin/rails db:seed
```

### 3. Access Application

- **HTTP**: http://localhost
- **HTTPS**: https://11b.dev (when domain is configured)
- **Admin**: http://localhost/admin (requires HTTP Basic Auth)

## Production Deployment

### Update Caddyfile

Edit `Caddyfile` with your domain:

```caddyfile
11b.dev www.11b.dev {
    reverse_proxy app:80
    
    # Optional: Enable compression
    encode gzip
    
    # Optional: Security headers
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
}
```

### SSL Certificates

Caddy automatically provisions SSL certificates from Let's Encrypt when:
- Your domain points to the server
- Ports 80 and 443 are accessible
- The domain is configured in Caddyfile

### Deploy

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker compose build --no-cache
docker compose down
docker compose up -d

# Run migrations
docker compose exec app bin/rails db:migrate
```

## Common Commands

### Application Management

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart services
docker compose restart

# View logs
docker compose logs -f app
docker compose logs -f caddy

# Access Rails console
docker compose exec app bin/rails console

# Run Rails commands
docker compose exec app bin/rails db:migrate
docker compose exec app bin/rails db:seed
```

### Database Management

```bash
# Backup SQLite database
docker compose exec app tar -czf - db/*.sqlite3 > backup-$(date +%Y%m%d).tar.gz

# Restore database
docker compose down
docker compose run --rm app tar -xzf - < backup-20251016.tar.gz
docker compose up -d
```

### Container Management

```bash
# View running containers
docker compose ps

# Check resource usage
docker compose stats

# Remove all containers and volumes (DESTRUCTIVE)
docker compose down -v
```

## Volumes

The following volumes persist data:

- `app_db`: SQLite database files
- `app_storage`: Active Storage uploads
- `app_logs`: Application logs
- `app_tmp`: Temporary files
- `caddy_data`: Caddy certificates and data
- `caddy_config`: Caddy configuration

### Backup Volumes

```bash
# Backup all volumes
docker run --rm \
  -v eleven_b_dev_app_db:/db \
  -v eleven_b_dev_app_storage:/storage \
  -v $(pwd):/backup \
  alpine tar czf /backup/volumes-backup-$(date +%Y%m%d).tar.gz /db /storage
```

## Monitoring

### Health Checks

Both containers have health checks configured:

```bash
# Check container health
docker compose ps

# View health check logs
docker inspect eleven_b_dev_app | grep -A 10 Health
```

### Access Logs

```bash
# Application logs
docker compose logs -f app

# Caddy access logs
docker compose logs -f caddy

# Follow specific service
docker compose logs -f app --tail=100
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker compose logs app

# Verify environment variables
docker compose config

# Check disk space
docker system df
```

### Database issues

```bash
# Access Rails console
docker compose exec app bin/rails console

# Check database
docker compose exec app bin/rails db:version

# Reset database (DESTRUCTIVE)
docker compose exec app bin/rails db:reset
```

### SSL Certificate issues

```bash
# Check Caddy logs
docker compose logs caddy

# Verify domain DNS
dig 11b.dev

# Test Caddy config
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile
```

## Security Notes

1. **Change default admin credentials** in production
2. **Use strong RAILS_MASTER_KEY** (never commit to git)
3. **Keep secrets in .env** (not tracked by git)
4. **Regular backups** of database and storage volumes
5. **Update Docker images** regularly for security patches

## Alternative: docker-compose.caddy.yml

The `docker-compose.caddy.yml` file is identical to `docker-compose.yml` and provided for clarity.

```bash
# Use specific compose file
docker compose -f docker-compose.caddy.yml up -d
```

## Performance Tuning

### For high-traffic sites:

```yaml
# Add to app service in docker-compose.yml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
    reservations:
      cpus: '1'
      memory: 1G
```

### Enable Rails caching:

```bash
docker compose exec app bin/rails dev:cache  # Toggle caching
```

## Support

- Issues: https://github.com/11bDev/11bdev-home/issues
- Docs: https://11b.dev
