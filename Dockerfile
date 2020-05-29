FROM php:7.2.9-fpm-alpine

LABEL maintainer "Jinlife <admin@jinlife.com>"

# Download customized Caddy
ARG plugins="git,cors,realip,expires,cache,cloudflare"
RUN curl --silent --show-error --fail --location \
    --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
    "https://caddyserver.com/download/linux/amd64?plugins=http.git,http.cors,http.realip,http.expires,http.cache,http.jwt,http.login,http.prometheus,http.restic&license=personal&telemetry=off" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
    && chmod 0755 /usr/bin/caddy \
    && /usr/bin/caddy -version

COPY Caddyfile /etc/Caddyfile

ENV CADDYPATH=/srv/caddycerts

WORKDIR /opt

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

# Timezone
RUN rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" /etc/timezone
	
# Support GD extension https://github.com/ThanisornJ/Docker-Laravel/blob/db92988506636273aa03e5101a47a5b52a6bfe73/docker-php-alpine/Dockerfile
RUN apk add --no-cache \
	freetype-dev libpng-dev libjpeg-turbo-dev freetype libpng libjpeg-turbo \
  && docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && docker-php-ext-install -j${NPROC} gd pdo pdo_mysql pdo_sqlite opcache zip \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

WORKDIR /srv/html

EXPOSE 80 443 2015
VOLUME /srv

ENTRYPOINT ["/bin/entrypoint.sh"]
