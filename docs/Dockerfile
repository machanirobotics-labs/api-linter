FROM ruby:3.4-alpine

# Install system dependencies
RUN apk add --no-cache \
  build-base \
  git \
  && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /code

# Copy Gemfile and Gemfile.lock first for better caching
COPY Gemfile Gemfile.lock ./

# Install bundler and gems
RUN gem update --system && \
  gem install bundler && \
  bundle config set --local deployment 'false' && \
  bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Set environment variables
ENV JEKYLL_ENV=development \
  PAGES_REPO_NWO=googleapis/googleapis.github.io

# Expose Jekyll server and LiveReload ports
EXPOSE 4000 35729

# Default command - can be overridden
CMD ["bundle", "exec", "jekyll", "serve", \
  "--destination", "/site", \
  "--host", "0.0.0.0", \
  "--livereload", \
  "--force_polling"]
