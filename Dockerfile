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
RUN docker-php-ext-install opcache mysqli pdo_mysql mbstring zip pcntl gd

WORKDIR /srv/html

EXPOSE 80 443 2015
VOLUME /srv

ENTRYPOINT ["/bin/entrypoint.sh"]
