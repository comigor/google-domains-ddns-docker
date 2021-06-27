FROM lsiobase/alpine:3.14

ENV INTERVAL=300

RUN apk add --no-cache curl

COPY root/ /

RUN chmod 755 "/ddns.sh"
