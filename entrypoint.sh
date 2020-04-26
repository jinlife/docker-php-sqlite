#!/bin/sh

chmod -R 777 /srv/html

if   [   $DOMAIN && $EMAIL   ]; 
then 
cat > /etc/Caddyfile << EOF
$DOMAIN {
    tls $EMAIL
    gzip
    cache
    fastcgi / 127.0.0.1:9000 php
    on startup php-fpm --nodaemonize
    rewrite {
        if {file} not feed.xml
        to {path} {path}/ /index.php?{query}
    }
    redir /feed.xml /feed 301
    root /srv/html
}
EOF
else 
cat > /etc/Caddyfile << EOF
:80 {
    gzip
    cache
    fastcgi / 127.0.0.1:9000 php
    on startup php-fpm --nodaemonize
    rewrite {
        if {file} not feed.xml
        to {path} {path}/ /index.php?{query}
    }
    redir /feed.xml /feed 301
    root /srv/html
}
EOF
fi

/usr/bin/caddy --conf /etc/Caddyfile --log stdout
