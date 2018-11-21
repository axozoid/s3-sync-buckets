FROM python:3.7-alpine3.8
RUN apk add bash --no-cache
RUN pip install awscli --disable-pip-version-check --no-cache-dir
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
