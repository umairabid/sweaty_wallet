# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.6
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /sweaty_wallet

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    NODE_PATH="/usr/local/lib/node_modules"


# Throw-away build stage to reduce size of final image
FROM base as build
ARG NODE_VERSION=18.x

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev \
    libffi-dev libyaml-dev zlib1g-dev libvips pkg-config curl zip

# Install node
RUN echo "Debugging NODE_VERSION: https://deb.nodesource.com/setup_${NODE_VERSION}"
RUN curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | bash -
RUN apt-get install -y nodejs

# Install application gems
COPY main_app/Gemfile main_app/Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node packages
COPY chrome_extension/package.json chrome_extension/package-lock.json ./
RUN npm_config_prefix=$NODE_PATH npm install

# Copy application code
COPY . .

# Build main app
WORKDIR /sweaty_wallet/main_app

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Build chrome extension
WORKDIR /sweaty_wallet/chrome_extension
RUN npm run build

WORKDIR /sweaty_wallet
RUN zip -r sweaty_wallet_chrome_extension.zip chrome_extension
RUN rm -rf chrome_extension
RUN rm -rf ./main_app/public/downloads/sweaty_wallet_chrome_extension.zip
RUN mv sweaty_wallet_chrome_extension.zip ./main_app/public/downloads


# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /sweaty_wallet/main_app /rails

WORKDIR /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
