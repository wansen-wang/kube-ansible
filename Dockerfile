FROM python:3.10.6-alpine3.16

COPY . /app

WORKDIR /app

RUN apk add --no-cache make bash \
    && make runtime

VOLUME [ "/app/inventory", "/app/group_vars", "/etc/ssl/kubernetes" ]

ENTRYPOINT [ "make" ]
CMD [ "help" ]