FROM openresty/openresty:1.19.9.1-12-bullseye

# Should we verify upstream's certificates? Default to true.
ENV VERIFY_SSL="true"
# Enable debugging mode; this inserts mitmproxy/mitmweb between the CONNECT proxy and the caching layer
ENV DEBUG="false"

USER root

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y supervisor curl unzip cron ca-certificates

RUN mkdir /cache \
    && groupadd -g 110 nginx \
    && useradd -u 110 -M -s /sbin/nologin -g nginx -d /cache -c "Nginx user" nginx

# Install AWS V2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

COPY files/scripts/  /
COPY files/ecr.ini /etc/supervisord.conf
COPY files/root /etc/crontabs/root

COPY files/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY files/conf/ecr-auth.conf /usr/local/openresty/nginx/conf/ecr-auth.conf
COPY files/conf/pull-through-server.conf /usr/local/openresty/nginx/conf/pull-through-server.conf
COPY files/conf/ssl.conf /usr/local/openresty/nginx/conf/ssl.conf
COPY files/conf/http-proxy-server.conf /usr/local/openresty/nginx/conf/http-proxy-server.conf


ENV PORT 5000
RUN chmod a+x /startup.sh /renew_token.sh

HEALTHCHECK --interval=5s --timeout=5s --retries=3 CMD /health-check.sh

ENTRYPOINT ["/startup.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
