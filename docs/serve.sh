#!/bin/bash
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------------------
#   This script runs a "development server" from Docker.
#   Usage:
#     ./serve.sh [--dev|--prod] [--incremental] [--livereload]
#
#   Options:
#     --dev          Development mode (default) - uses localhost URLs
#     --prod         Production mode - uses production URLs from _config.yml
#     --incremental  Enable incremental builds (faster rebuilds)
#     --livereload   Enable live reload (enabled by default in dev mode)
# -----------------------------------------------------------------------------

# Parse mode
MODE="dev"
JEKYLL_ARGS=""
INCREMENTAL=""
LIVERELOAD="--livereload"

for arg in "$@"; do
  case $arg in
    --prod)
      MODE="prod"
      shift
      ;;
    --dev)
      MODE="dev"
      shift
      ;;
    --incremental)
      INCREMENTAL="--incremental"
      shift
      ;;
    --livereload)
      LIVERELOAD="--livereload"
      shift
      ;;
    --no-livereload)
      LIVERELOAD=""
      shift
      ;;
    *)
      JEKYLL_ARGS="$JEKYLL_ARGS $arg"
      ;;
  esac
done

# Build the image (if and only if it is not already built).
if [[ "$(docker images -q googleapis-site 2> /dev/null)" == "" ]]; then
  echo "Building Docker image..."
  docker build -t googleapis-site .
  if [ $? != 0 ]; then
    exit $?
  fi
fi

# Unless we are in incremental mode, the source filesystem should
# be read-only. Incremental mode sadly requires writing a file to the
# source directory.
READ_ONLY=',readonly'
if [[ -n "$INCREMENTAL" ]]; then
  READ_ONLY=''
fi

# Set up environment and Jekyll arguments based on mode
if [[ "$MODE" == "prod" ]]; then
  echo "Starting in PRODUCTION mode..."
  JEKYLL_ENV="production"
  # In production mode, use the URL from _config.yml
  EXTRA_ARGS=""
else
  echo "Starting in DEVELOPMENT mode..."
  JEKYLL_ENV="development"
  # In dev mode, override URL to localhost for proper redirect testing
  EXTRA_ARGS="--config _config.yml,_config_dev.yml"
  
  # Always create/update dev config for consistency
  echo "Creating _config_dev.yml for local development..."
  cat > _config_dev.yml << EOF
# Development overrides
url: http://localhost:4000
baseurl: ""
EOF
fi

# Build the final command array
JEKYLL_CMD=("bundle" "exec" "jekyll" "serve" "--destination" "/site" "--host" "0.0.0.0")

# Add optional flags
if [[ -n "$INCREMENTAL" ]]; then
  JEKYLL_CMD+=("--incremental")
fi

if [[ -n "$LIVERELOAD" ]]; then
  JEKYLL_CMD+=("--livereload" "--force_polling")
fi

# Add config files
if [[ "$MODE" == "dev" ]]; then
  JEKYLL_CMD+=("--config" "_config.yml,_config_dev.yml")
else
  JEKYLL_CMD+=("--config" "_config.yml")
fi

# Run the image.
echo "Starting Jekyll server..."
docker run --rm \
  -e JEKYLL_ENV=$JEKYLL_ENV \
  -p 4000:4000/tcp   -p 4000:4000/udp   \
  -p 35729:35729/tcp -p 35729:35729/udp \
  --mount type=bind,source=`pwd`,destination=/code/${READ_ONLY} \
  googleapis-site \
  "${JEKYLL_CMD[@]}" $JEKYLL_ARGS
