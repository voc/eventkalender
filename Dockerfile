FROM ruby:2.6.5-alpine3.10

RUN apk -U add gcc make libc-dev linux-headers g++ \
 && gem install unicorn rack\
 && addgroup -S unicorn \
 && adduser -h /unicorn -s /bin/false -S -D -H -G unicorn unicorn \
 && install -d /var/log/unicorn -o unicorn -g unicorn \
 && ln -s /dev/stdout /var/log/unicorn/stdout.log \
 && ln -s /dev/stderr /var/log/unicorn/stderr.log

COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/unicorn.rb /etc/unicorn.rb

ADD --chown=unicorn . /eventkalender

WORKDIR /eventkalender
RUN bundle install

USER unicorn
WORKDIR /eventkalender

EXPOSE 8000

# Inject environment variables in config files
ENTRYPOINT [ "/entrypoint.sh" ]
# Run unicorn
CMD [ "unicorn", "-c", "/etc/unicorn.rb"]