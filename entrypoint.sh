#!/bin/sh

chmod -R 777 /srv/html

if [[  "x$DOMAIN" != "x" &&  "x$EMAIL" != "x"  ]]
then

cat > /etc/Caddyfile << EOF
$DOMAIN {
    tls $EMAIL
    encode zstd gzip # optional compression
    php_fastcgi 127.0.0.1:9000
	@try_files {
		not path *feed.xml
		file {
			try_files {path} {path}/ /index.php
		}
	}
	rewrite @try_files {http.matchers.file.relative}
    redir /feed.xml /feed 301
    root * /srv/html
}
EOF

else 

cat > /etc/Caddyfile << EOF
:80 {
    encode zstd gzip # optional compression
    php_fastcgi 127.0.0.1:9000
	@try_files {
		not path *feed.xml
		file {
			try_files {path} {path}/ /index.php
		}
	}
	rewrite @try_files {http.matchers.file.relative}
    redir /feed.xml /feed 301
    root * /srv/html
}
EOF

fi

nohup php-fpm --nodaemonize --allow-to-run-as-root 2>&1 &
/usr/bin/caddy run --config /etc/Caddyfile --adapter caddyfile
