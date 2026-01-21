# Docker Setup for API Linter Documentation

This directory contains Docker configurations for running the Jekyll documentation site locally.

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Development mode (default) - with live reload
docker-compose up docs

# With custom local domain
LOCAL_URL=http://gapi.docs.machanirobotics.local:4000 docker-compose up docs

# Or create .env file with LOCAL_URL=http://gapi.docs.machanirobotics.local:4000
echo "LOCAL_URL=http://gapi.docs.machanirobotics.local:4000" > .env
docker-compose up docs

# Production mode
docker-compose --profile prod up docs-prod

# Incremental builds (faster rebuilds)
docker-compose --profile incremental up docs-incremental

# Build and start
docker-compose up --build docs

# Stop and remove containers
docker-compose down
```

### Setting Up Local DNS

To use a custom domain like `gapi.docs.machanirobotics.local`:

1. **Get your machine's IP:**
   ```bash
   ip addr show | grep "inet " | grep -v 127.0.0.1
   ```

2. **Add to `/etc/hosts` on each device:**
   ```bash
   # Linux/Mac: /etc/hosts
   # Windows: C:\Windows\System32\drivers\etc\hosts
   192.168.x.x   gapi.docs.machanirobotics.local
   ```

3. **Create `.env` file:**
   ```bash
   echo "LOCAL_URL=http://gapi.docs.machanirobotics.local:4000" > .env
   ```

4. **Start with custom domain:**
   ```bash
   docker-compose up docs
   ```

5. **Access at:** `http://gapi.docs.machanirobotics.local:4000`

### Using the Shell Script

```bash
# Development mode (default)
./serve.sh

# Production mode
./serve.sh --prod

# With incremental builds
./serve.sh --dev --incremental

# Production with incremental
./serve.sh --prod --incremental
```

## Access the Site

Once running, access the documentation at:
- **Development**: http://localhost:4000
- **LiveReload**: Automatically enabled in dev mode

## Configuration

### Development Mode
- Uses `_config.yml` + `_config_dev.yml` (auto-generated)
- URL: `http://localhost:4000`
- LiveReload enabled
- Redirects work properly on localhost

### Production Mode
- Uses only `_config.yml`
- URL: Production URL from config
- No LiveReload
- Read-only volume mount

## Troubleshooting

### Port Already in Use
```bash
# Stop existing containers
docker-compose down

# Or use different ports by editing docker-compose.yml
```

### Changes Not Reflecting
```bash
# Rebuild the image
docker-compose up --build docs

# Or use incremental mode
docker-compose --profile incremental up docs-incremental
```

### Clear Cache
```bash
# Remove volumes and rebuild
docker-compose down -v
docker-compose up --build docs
```

## Docker Compose Services

- **docs**: Default development server with live reload
- **docs-prod**: Production mode (use `--profile prod`)
- **docs-incremental**: Incremental builds for faster development (use `--profile incremental`)

## Volume Mounts

- `.:/code`: Source code (read-write in dev, read-only in prod)
- `bundle_cache:/usr/local/bundle`: Gem cache for faster rebuilds
