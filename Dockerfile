FROM php:7.2-fpm-alpine

LABEL maintainer "Jinlife <admin@jinlife.com>"

RUN curl --silent --show-error --fail --location \
    --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
    "https://caddyserver.com/download/linux/amd64?plugins=http.expires,http.realip&license=personal" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
    && chmod 0755 /usr/bin/caddy \
    && /usr/bin/caddy -version

COPY Caddyfile /etc/Caddyfile
# Let's Encrypt Agreement
ENV ACME_AGREE="false"

ENV CADDYPATH=/srv/caddycerts

WORKDIR /opt

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

#Timezone
RUN rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" /etc/timezone
	
#Support GD extension
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  docker-php-ext-install -j${nproc} gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

WORKDIR /srv/html

EXPOSE 80 443 2015
VOLUME /srv

ENTRYPOINT ["/bin/entrypoint.sh"]
