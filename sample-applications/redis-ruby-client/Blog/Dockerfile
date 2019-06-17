FROM ruby:2.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .


EXPOSE 3000
ENV RAILS_ENV=development
CMD ["rails", "s", "-b", "0.0.0.0"]