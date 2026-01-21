# Docker Setup for API Linter Documentation

This directory contains Docker configurations for running the Jekyll documentation site locally.

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Development mode (default) - with live reload
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
