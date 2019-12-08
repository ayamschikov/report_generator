FROM ruby:2.6.3-slim-stretch

WORKDIR /app

RUN apt-get update -qqy && apt-get install -y --no-install-recommends --no-install-suggests \
  build-essential
# RUN apt-get install libgmp3-dev

COPY . /app

RUN bundle install

EXPOSE 8090

