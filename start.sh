#!/bin/bash
set -e

#Replace php-fpm configuration pm.max_children in www.conf.
if [[ -n "$MAX_CHILDREN" && "$MAX_CHILDREN" -gt 0 ]] ;then
	sed -i "s/^pm.max_children =.*/pm.max_children = $MAX_CHILDREN/g" /etc/php/7.0/fpm/pool.d/www.conf
fi    

/etc/init.d/nginx restart
/etc/init.d/ssh restart
/etc/init.d/memcached restart
/etc/init.d/php7.0-fpm start

/bin/bash