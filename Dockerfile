FROM ruby:alpine

RUN apk update && apk add docker build-base git curl

ADD bin /app/bin
ADD exe /app/exe
ADD lib /app/lib
ADD spec /app/spec
ADD Gemfile Gemfile.lock kaiser.gemspec Rakefile entrypoint.sh /app/

WORKDIR /app

RUN echo 'gem: --no-rdoc --no-ri' > ~/.gemrc && gem build kaiser.gemspec && gem install `ls *.gem`

ENTRYPOINT ["sh", "entrypoint.sh"]
