FROM alpine:3.20

RUN apk add --no-cache \
    curl \
    grep \
    sed \
    coreutils \
    ca-certificates

COPY set-qbt-port.sh /set-qbt-port.sh
RUN chmod +x /set-qbt-port.sh

ENTRYPOINT ["/set-qbt-port.sh"]
