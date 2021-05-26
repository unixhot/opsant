# Base Image
FROM python:3.6.12-alpine3.11

# Install PATH
RUN mkdir /opt/opsant && mkdir /etc/supervisord.d

# Add File
ADD opsant-backend /opt/opsant-backend

# Install
RUN cd /etc/apk/keys/ && wget 'http://openresty.org/package/admin@openresty.com-5ea678a6.rsa.pub' \
&& sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
&& echo "http://openresty.org/package/alpine/v3.11/main" >> /etc/apk/repositories && apk update \
&& apk add --no-cache gcc g++ make libffi-dev openssl-dev zlib-dev jpeg-dev mariadb-dev openssh-client openresty \
&& pip --no-cache-dir install supervisor -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com \
&& pip --no-cache-dir install -r /opt/opsant-backend/requirements.txt -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com

#Supervisord config
ADD supervisord.conf /etc/supervisord.conf
ADD websocket.ini /etc/supervisord.d/websocket.ini
ADD opsant.ini /etc/supervisord.d/opsant.ini
ADD openresty.ini /etc/supervisord.d/openresty.ini

# Outside Port
EXPOSE 80
EXPOSE 443

#supervisord start
CMD ["supervisord", "-c", "/etc/supervisord.conf"]