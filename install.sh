#!/bin/bash
#******************************************
# Author:       Jason Zhao
# Email:        zhaoshundong@opsant.com
# Organization: https://www.opsany.com/
# Description:  OpsAnt Install Script
#******************************************

#Data/Time
CTIME=$(date "+%Y-%m-%d-%H-%M")

#Shell ENV
SHELL_NAME="install.sh"
SHELL_LOG="${SHELL_NAME}.log"
INSTALL_PATH="/opt/opsant"

#Check Config 
if [ ! -f ./install.config ];then
      echo "Please Copy install.config and Change: cp install.config.example install.config"
      exit
else
    source ./install.config
fi

# generate ssl certs
ssl_make(){
    base_dir=$(pwd)
    source ./generate-ssl.sh
    cd $base_dir
}
# Record Shell log
shell_log(){
  LOG_INFO=$1
  echo "----------------$CTIME ${SHELL_NAME} : ${LOG_INFO}----------------"
  echo "$CTIME ${SHELL_NAME} : ${LOG_INFO}" >> ${SHELL_LOG}
}


# Check Install requirement
install_check(){
  DOCKER_PID=$(ps aux | grep '/usr/bin/containerd' | grep -v 'grep' | wc -l)
  if [ ${DOCKER_PID} -lt 1 ];then
      echo "Please install and start docker first!!!"
      exit
  fi
}

# Install Init
opsant_init(){
    shell_log "Start: Install Init"
    mkdir -p ${INSTALL_PATH}/{uploads/guacamole,logs,redis-volume,mongodb-volume,mysql-volume}
    /bin/cp -r conf ${INSTALL_PATH}/
    #/bin/cp -r agent ${INSTALL_PATH}/uploads/
    shell_log "End: Install Init"
}

# Share Service Start
opsant_install(){
    # Redis
    shell_log "======启动Redis======"
    sed -i "s/REDIS_SERVER_PASSWORD/${REDIS_SERVER_PASSWORD}/g" ${INSTALL_PATH}/conf/redis.conf
    docker run -d --restart=always --name opsant-redis \
      -p 6379:6379 -v ${INSTALL_PATH}/redis-volume:/data \
      -v ${INSTALL_PATH}/conf/redis.conf:/data/redis.conf \
      opsany/redis:6.0.9-alpine redis-server /data/redis.conf

    # MySQL
    shell_log "======启动MySQL======"
    docker run -d --restart=always --name opsant-mysql \
      -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
      -p 3306:3306 -v ${INSTALL_PATH}/mysql-volume:/var/lib/mysql \
      -v ${INSTALL_PATH}/conf/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf \
      -v ${INSTALL_PATH}/logs:/var/log/mysql \
      opsany/mysql:5.6.50 --character-set-server=utf8 --collation-server=utf8_general_ci

    # Guacd
    shell_log "======启动Guacd======"
    docker run -d --restart=always --name opsant-guacd \
      -p 4822:4822 \
      -v ${INSTALL_PATH}/uploads/guacamole:/srv/guacamole \
      opsany/guacd:1.2.0
}

# MySQL init
mysql_init(){
    shell_log "======进行MySQL数据初始化======"
    sleep 20
    export MYSQL_PWD=${MYSQL_ROOT_PASSWORD}
    mysql -h "${LOCAL_IP}" -u root  -e "CREATE DATABASE IF NOT EXISTS opsant DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    mysql -h "${LOCAL_IP}" -u root  -e "grant all on opsant.* to opsant@'%' identified by "\"${MYSQL_OPSANT_PASSWORD}\"";" 
    #mysql -h "${LOCAL_IP}" -u root  opsant < opsant.sql
}

# Config
opsant_config(){
    shell_log "======进行OpsAnt配置修改======"
    # PaaS Config
    sed -i "s/MYSQL_SERVER_IP/${MYSQL_SERVER_IP}/g" ${INSTALL_PATH}/conf/prod.py
    sed -i "s/MYSQL_OPSANT_PASSWORD/${MYSQL_OPSANT_PASSWORD}/g" ${INSTALL_PATH}/conf/prod.py
    sed -i "s/REDIS_SERVER_IP/${REDIS_SERVER_IP}/g" ${INSTALL_PATH}/conf/prod.py
    sed -i "s/REDIS_SERVER_PASSWORD/${REDIS_SERVER_PASSWORD}/g" ${INSTALL_PATH}/conf/prod.py
    sed -i "s/GUACD_SERVER_IP/${GUACD_SERVER_IP}/g" ${INSTALL_PATH}/conf/prod.py

    # OpenResty
    sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" ${INSTALL_PATH}/conf/nginx-conf.d/opsant.conf
    sed -i "s/LOCAL_IP/${LOCAL_IP}/g" ${INSTALL_PATH}/conf/nginx-conf.d/opsant.conf
}

opsant_start(){
    shell_log "======启动OpsAnt服务======"
    docker run -d --restart=always --name opsant-web \
      -p 80:80 -p 443:443 -v ${INSTALL_PATH}/logs:/opt/opsant/logs \
      -v ${INSTALL_PATH}/conf/nginx-conf.d:/usr/local/openresty/nginx/conf.d \
      -v ${INSTALL_PATH}/conf/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
      -v ${INSTALL_PATH}/conf/prod.py:/opt/opsant-backend/config/prod.py \
      -v ${INSTALL_PATH}/uploads:/opt/opsant/uploads \
      opsany/opsant:${OPSANT_VERSION}
}

opsant_set(){
    shell_log "======初始化数据库和admin用户密码======"
    sleep 20
    ADMIN_PASSWD=$(openssl rand -base64 8)
    docker exec -e OPS_ANT_ENV=production opsant-web sh -c "/usr/local/bin/python3 /opt/opsant-backend/manage.py migrate"
    docker exec -e OPS_ANT_ENV=production opsant-web sh -c "/usr/local/bin/python3 /opt/opsant-backend/manage.py create_user --password $ADMIN_PASSWD"
    echo "======OpsAnt容器化部署完毕======"
    echo "访问地址https://${DOMAIN_NAME}"
    echo "初始化用户名：admin 密码：$ADMIN_PASSWD 请及时修改密码。默认保存在/tmp/opsant.password"
    echo "$ADMIN_PASSWD" > /tmp/opsant.password
}

main(){
    install_check
    ssl_make
    opsant_init
    opsant_install
    mysql_init
    opsant_config
    opsant_start
    opsant_set
}

main
