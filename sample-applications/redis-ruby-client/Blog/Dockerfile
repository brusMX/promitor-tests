FROM ruby:2.3.7

RUN apt-get update

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .


EXPOSE 3000
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=enabled

ENV RUBY_GC_MALLOC_LIMIT=4000100
ENV RUBY_GC_MALLOC_LIMIT_MAX=16000100
ENV RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.1

RUN rails assets:precompile

CMD ["rails", "s", "-b", "0.0.0.0"]