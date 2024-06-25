FROM nginx:alpine
WORKDIR /app
COPY dist.tgz ./
RUN tar -xvzf dist.tgz
RUN chown -R nginx:nginx apps
RUN cp -r apps/nx/dist/. /usr/share/nginx/html/.
COPY --chown=nginx:nginx server.crt /etc/ssl/certs/server.crt
COPY --chown=nginx:nginx server.key /etc/ssl/private/server.key
