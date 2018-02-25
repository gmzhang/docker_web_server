FROM ubuntu:14.04

MAINTAINER gmzhang <cnguangming@gmail.com>

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN echo "Asia/Shanghai" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

ENV HOME /root

COPY sources.list.trusty /etc/apt/sources.list
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim git curl wget build-essential software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes nginx php7.0-cli php7.0-fpm php7.0-mysql php7.0-curl php7.0-dev\
		       php7.0-gd php7.0-mcrypt php7.0-intl php7.0-imap php7.0-zip php7.0-tidy php-memcached php7.0-xml php-xdebug php7.0-bcmath

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y openssh-server memcached

RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Shanghai/" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Shanghai/" /etc/php/7.0/cli/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;opcache.enable=0/opcache.enable=1/" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=4000/" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;opcache.fast_shutdown=.*/opcache.fast_shutdown=1/" /etc/php/7.0/fpm/php.ini

#set php file and memory limit
RUN sed -i "s/upload_max_filesize\s*=\s*.*/upload_max_filesize = 200M/" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/post_max_size\s*=\s*.*/post_max_size = 200M/" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/memory_limit\s*=\s*.*/memory_limit = 256M/" /etc/php/7.0/fpm/php.ini


RUN mkdir -p      /var/www/log/web/  /var/www/web

COPY default   /etc/nginx/sites-available/default
COPY www.conf /etc/php/7.0/fpm/pool.d/www.conf
COPY nginx.conf /etc/nginx/nginx.conf

ENV HOME /root



RUN mkdir /var/run/sshd
RUN echo 'root:123' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#set http-proxy
RUN export http_proxy=http://mudutv:crosswall@mudu.ns.4l.hk:51873 && \
    export https_proxy=http://mudutv:crosswall@mudu.ns.4l.hk:51873

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nodejs

#unset http-proxy
RUN unset http_proxy && \
    unset https_proxy

RUN npm install -g cnpm --registry=https://registry.npm.taobao.org

RUN npm config set https-proxy http://mudutv:crosswall@mudu.ns.4l.hk:51873
RUN npm config set http-proxy http://mudutv:crosswall@mudu.ns.4l.hk:51873


RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    sudo apt-get update && sudo apt-get install -y yarn


EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD start.sh /start.sh
RUN chmod 755 /start.sh

ENTRYPOINT ["/start.sh"]
