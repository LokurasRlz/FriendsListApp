FROM ruby:3.1.3-alpine3.16

ENV RUBY_VERSION 3.1.3
ENV APP_HOME /app
WORKDIR $APP_HOME

# Update / Install the dependencies for start the container
RUN apk update && apk --no-cache add build-base postgresql-dev nodejs yarn

# Install dependencies for the our application
RUN apk --no-cache update \
    && apk --no-cache add libxml2 libxslt \
    && apk --no-cache add libc6-compat \
    && gem update --system 3.4.12 \
    && gem install nokogiri -- --use-system-libraries \
    && apk --no-cache add git \
    && apk --no-cache add postgresql-contrib \
    && apk --no-cache add imagemagick

# For sending the logs to the docker logs manager.
RUN ln -sf /dev/bd_logs /tmp/

# Copy the files from the host to the container
COPY . $APP_HOME
RUN chmod +x docker/start.sh

# install the gems from the Gemfile its a separated layer to prevent rebuild the gems
# when the code changes or the Gemfile.lock changes
COPY . $APP_HOME
RUN bundle install

# Precompile the assets
RUN bundle exec rake assets:precompile

# Ensure Rails serves static files
ENV RAILS_SERVE_STATIC_FILES=true

# This are the ports exposed by the container
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
