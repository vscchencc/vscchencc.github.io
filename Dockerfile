FROM nginx:1.21
 
RUN rm -rf /etc/nginx/nginx.conf
 
COPY ./nginx.conf /etc/nginx/nginx.conf
 
COPY ./public/  /usr/share/nginx/html

CMD nginx -g "daemon off;"