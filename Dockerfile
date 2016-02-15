FROM undeadops/alpine-pyapp:3.3

MAINTAINER Mitch Anderson "mitch@metauser.net"

RUN pip install pelican Markdown

ADD . /source

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default /etc/nginx/sites-enabled/default
COPY nginx/ssl/metauser.net.key /etc/nginx/ssl/
COPY nginx/ssl/metauser.net.pem /etc/nginx/ssl/

WORKDIR /source

RUN pelican ./content/

RUN rm -rf /www/* \
  && cp -R ./output/* /www/

# I don't know if this is needed.. 
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
