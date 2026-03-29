#!/bin/sh
set -e

rm -f /app/tmp/pids/server.pid

bundle check || bundle install

if [ "${RAILS_ENV}" = "production" ]; then
  mkdir -p /public-assets
  rm -rf /public-assets/*
  SECRET_KEY_BASE="${SECRET_KEY_BASE:-dummy}" bundle exec rails assets:precompile
  cp -R /app/public/. /public-assets/
fi

exec bundle exec puma -C config/puma.rb
