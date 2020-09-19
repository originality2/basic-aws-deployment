FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /hello-world
WORKDIR /hello-world
COPY Gemfile /hello-world/Gemfile
COPY config.ru /hello-world/config.ru
RUN bundle install
COPY . /hello-world

# Add a script to be executed every time the container starts.
EXPOSE 3000

# Start the main process.
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "3000"]
