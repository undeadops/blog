FROM debian:jessie
MAINTAINER Mitch Anderson "mitch@metauser.net"

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.9.9-1~jessie

RUN apt-get update && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION} && \
    apt-get install -y python-pip && \
    rm -rf /var/lib/apt/lists/*

RUN pip install pelican Markdown

RUN mkdir /source
RUN mkdir /www
RUN mkdir /etc/nginx/ssl
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
