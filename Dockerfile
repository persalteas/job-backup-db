FROM alpine:3.19.0

ENV BAGCLI_RETENTION_TIME=7d
ENV BAGCLI_REMOTE_PATH=backup
ENV BAGCLI_DATABASE_HOST=localhost
ENV BAGCLI_DATABASE_PORT=5432
ENV BAGCLI_DATABASE_OPTIONS="-c work_mem=100MB"
ENV BAGCLI_DATABASE_NAME=test
ENV BAGCLI_DATABASE_URI=mongodb://mongoadmin:secret@mongodb-arbiter-0.mongodb-arbiter-headless.database:27017,mongodb-0.mongodb-headless.database:27017,mongodb-1.mongodb-headless.database:27017/mongodb_d_test?replicaSet=rs0&authSource=admin&retryWrites=true&w=majority
ENV BAGCLI_HEARTBEAT_URL=""
ENV BAGCLI_WEBHOOK_URL=""
ENV BAGCLI_WEBHOOK_CHANNEL=""

WORKDIR /backup-cli

RUN apk add --no-cache --update rclone postgresql-client mariadb-client mongodb-tools bash curl

RUN addgroup -S job \
    && adduser --uid 1010 -G job --home /home/job -S --shell /bin/bash job

COPY main.sh /usr/bin/backup
COPY src/ ./

RUN chmod +x /usr/bin/backup \
    && chmod +x -R ./commands \
    && chown -R job /usr/bin/backup \
    && chown -R job ./commands

USER job

ENTRYPOINT [ "backup" ]

CMD [ "postgres" ]