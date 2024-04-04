FROM nginx:stable-alpine

RUN apk --update upgrade && \
    apk add git git-daemon fcgiwrap spawn-fcgi

RUN mkdir -p /var/www/git           && \
    adduser git -h /var/www/git -D  && \
    adduser nginx git               && \
    chmod g+w /var/www/git          && \
    chown git:git /var/www/git
  
RUN git config --system http.receivepack true    && \
    git config --system http.uploadpack true     && \
    git config --global init.defaultBranch main
 
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.disabled
COPY git.conf /etc/nginx/conf.d/git.conf
COPY git-repo.sh /usr/local/bin/git-repo
COPY nginx.conf /etc/nginx/nginx.conf

RUN chgrp -R root /var/cache/nginx /var/run /var/log/nginx /var/www/git && \
    chmod -R 770 /var/cache/nginx /var/run /var/log/nginx

RUN adduser nginx root  && \
    adduser git root

USER git

EXPOSE 8080

CMD /usr/bin/spawn-fcgi -s /tmp/fcgiwrap.socket -u nginx -g nginx -U nginx -G git /usr/bin/fcgiwrap && nginx -g "daemon off;"
