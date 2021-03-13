FROM php:7.4-fpm-alpine

LABEL maintainer "jinlife <glucose1e@tom.com>"

# Download customized Caddy
RUN set -eux; \
        wget -O /usr/bin/caddy "https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Fcloudflare"; \
        chmod +x /usr/bin/caddy; \
        caddy version

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
	freetype-dev libpng-dev libjpeg-turbo-dev freetype libpng libjpeg-turbo sqlite-dev libzip-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && docker-php-ext-install -j${NPROC} gd pdo pdo_mysql pdo_sqlite opcache zip \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

WORKDIR /srv/html

EXPOSE 80 443 2015
VOLUME /srv

ENTRYPOINT ["/bin/entrypoint.sh"]
