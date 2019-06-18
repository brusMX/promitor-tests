FROM ruby:2.3.7

RUN apt-get update

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .


EXPOSE 3000
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=enabled
ENV RAILS_SERVE_STATIC_FILES=true

ENV RUBY_GC_MALLOC_LIMIT=40000000
ENV RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.1

RUN rails assets:precompile

CMD ["rails", "s", "-b", "0.0.0.0"]