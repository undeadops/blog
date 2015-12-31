FROM ubuntu:wily
MAINTAINER Mitch Anderson "mitch@metauser.net"

ENV NGINX_VERSION 1.9.9-0+wily0

RUN apt-get update && \ 
         DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade && \
         DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install python3-pip software-properties-common && \
         DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:nginx/development && \
         apt-get clean all && \
         rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install nginx=${NGINX_VERSION} && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip3 install pelican Markdown

RUN mkdir /source && \
    mkdir /www && \
    mkdir /etc/nginx/ssl

ADD . /source

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default /etc/nginx/sites-enabled/default 
COPY nginx/ssl/metauser.net.key /etc/nginx/ssl/
COPY nginx/ssl/metauser.net.pem /etc/nginx/ssl/

WORKDIR /source

RUN pelican ./content/

RUN rm -rf /www/*
RUN cp -R ./output/* /www/

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
