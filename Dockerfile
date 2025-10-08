FROM ruby:3.3.9-alpine3.22

RUN apk -U add gcc make libc-dev linux-headers g++ \
 && addgroup -S puma \
 && adduser -h /puma -s /bin/false -S -D -G puma puma

COPY scripts/entrypoint.sh /entrypoint.sh

ADD --chown=puma . /eventkalender

WORKDIR /eventkalender

USER puma

RUN gem install rack rackup puma --user-install \
 && bundle install


EXPOSE 8000

# Inject environment variables in config files
ENTRYPOINT [ "/entrypoint.sh" ]
# Run puma
CMD [ "puma", "-b", "tcp://0.0.0.0", "-p", "8000" ]
