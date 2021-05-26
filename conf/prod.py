# -*- coding: utf-8 -*-
# 生产环境配置文件
from config.default import *

RUN_MODE = 'PRODUCT'
BROKER_URL = 'redis://:REDIS_SERVER_PASSWORD@REDIS_SERVER_IP:6379/8'
OPS_ANT_COOKIE_NAME = 'opsant_token'
OPS_ANT_COOKIE_AGE = 60 * 60 * 24
DEBUG = False

# 本地开发数据库设置
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'opsant',
        'USER': 'opsant',
        'PASSWORD': 'MYSQL_OPSANT_PASSWORD',
        'HOST': 'MYSQL_SERVER_IP',
        'PORT': '3306',
    },
}

# Celery使用
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            'hosts': ['redis://:REDIS_SERVER_PASSWORD@REDIS_SERVER_IP:6379/7'],
            "symmetric_encryption_keys": [SECRET_KEY],
        },
    }
}

# 静态文件访问路径
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, "static")

# Windows堡垒机访问配置
GUACD_HOST = 'GUACD_SERVER_IP'
GUACD_PORT = '4822'
ORI_GUACD_PATH = '/opt/opsant/uploads/guacamole/'
GUACD_PATH = '/srv/guacamole'

# Linux堡垒机访问配置
TERMINAL_TIMEOUT = 1800
TERMINAL_PATH = '/opt/opsant/uploads/terminal'

# 初始化用户配置
ADMIN_PASSWORD = 'admin'
ADMIN_EMAIL = 'admin@example.com'
ADMIN_PHONE = '13666666666'
