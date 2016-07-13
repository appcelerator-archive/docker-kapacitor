FROM appcelerator/amp:latest
MAINTAINER Nicolas Degory <ndegory@axway.com>

ENV KAPACITOR_VERSION 0.13.1

RUN apk update && apk upgrade && \
    apk -v --virtual build-deps add --update go>1.6 curl git gcc musl-dev && \
    export GOPATH=/go && \
    go get -v github.com/influxdata/kapacitor && \
    cd $GOPATH/src/github.com/influxdata/kapacitor && \
    git checkout -q --detach "v${KAPACITOR_VERSION}" && \
    go get -v ./... && \
    go build -v ./cmd/kapacitor && \
    go build -v ./cmd/kapacitord && \
    mv $GOPATH/bin/* /bin/ && \
    mkdir -p /var/lib/kapacitor && \
    apk del build-deps && cd / && rm -rf /var/cache/apk/* $GOPATH

EXPOSE 9092

VOLUME /var/lib/kapacitor

ENV INFLUXDB_URL http://localhost:8086
ENV INFLUXDB_DB telegraf
ENV INFLUXDB_RP default

#ENV CONSUL=consul:8500
ENV CP_SERVICE_NAME=kapacitor
ENV CP_SERVICE_BIN=kapacitord
ENV CP_SERVICE_PORT=9092
ENV CP_TTL=20
ENV CP_POLL=5
ENV CP_DEPENDENCIES='[{"name": "influxdb"}, {"name": "amp-log-agent", "onChange": "ignore"} ]'

COPY run.sh /run.sh
COPY kapacitor.conf /etc/kapacitor.conf.tpl
COPY e494ce6c-d063-46f8-9d71-9030a29eef4b.srpl /.kapacitor/replay/e494ce6c-d063-46f8-9d71-9030a29eef4b.srpl

CMD ["/start.sh"]

LABEL axway_image=kapacitor
# will be updated whenever there's a new commit
LABEL commit=${GIT_COMMIT}
LABEL branch=${GIT_BRANCH}
