FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y curl apt-transport-https wget && \ 
    apt-get update -qq && apt-get -y install build-essential libpq-dev nodejs mariadb-client
RUN mkdir /myapp
WORKDIR /myapp
RUN echo "install: –no-document" > .gemrc && echo "update: –no-document" >> .gemrc
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
