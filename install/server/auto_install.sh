#!/bin/bash
set -e

# 初始化环境目录
main_dir="/var/opt/adminset"
adminset_dir="$main_dir/main"
data_dir="$main_dir/data"
config_dir="$main_dir/config"
logs_dir="$main_dir/logs"
client_dir="$main_dir/client"
cd "$( dirname "$0"  )"
cd .. && cd ..
cur_dir=$(pwd)
echo "current dir:"$cur_dir
mkdir -p $adminset_dir
mkdir -p $data_dir/scripts
mkdir -p $data_dir/ansible/playbook
mkdir -p $data_dir/ansible/roles
mkdir -p $config_dir
mkdir -p $logs_dir
mkdir -p $main_dir/pid
mkdir -p $client_dir



# 安装依赖
echo "####install depandencies####"
yum install -y epel-release
yum install -y gcc expect python-pip python-devel ansible smartmontools dmidecode libselinux-python git rsync dos2unix
yum install -y openssl openssl-devel


/usr/bin/npm install -g cnpm --registry=https://registry.npm.taobao.org
/usr/bin/cnpm install --production
/usr/bin/cnpm install forever -g


scp $adminset_dir/install/server/ansible/ansible.cfg /etc/ansible/ansible.cfg



#安装数据库
echo "####install database####"
echo "installing a new mariadb...."
yum install -y mariadb-server mariadb-devel
service mariadb start
chkconfig mariadb on
mysql -e "CREATE DATABASE if not exists adminset DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"


# 安装mongodb
echo "####install mongodb####"
echo "installing a new Mongodb...."
yum install -y mongodb mongodb-server
/bin/systemctl start mongod 
/bin/systemctl enable mongod 

# 安装主程序
#echo "####install adminset####"
#mkdir -p  ~/.pip
#cat <<EOF > ~/.pip/pip.conf
#[global]
#index-url = http://mirrors.aliyun.com/pypi/simple/
#
#[install]
#trusted-host=mirrors.aliyun.com
#EOF


#source /etc/profile
#/usr/bin/mysql -e "insert into adminset.accounts_userinfo (password,username,email,is_active,is_superuser) values ('pbkdf2_sha256\$24000\$2odRjOCV1G1V\$SGJCqWf0Eqej6bjjxusAojWtZkz99vEJlDbQHUlavT4=','admin','admin@126.com',1,1);"
#scp $adminset_dir/install/server/adminset.service /usr/lib/systemd/system
#chkconfig adminset on
#service adminset start

##安装redis
#echo "####install redis####"
#yum install redis -y
#chkconfig redis on
#service redis start

# 安装celery
echo "####install celery####"
mkdir -p $config_dir/celery
scp $adminset_dir/install/server/celery/beat.conf $config_dir/celery/beat.conf
scp $adminset_dir/install/server/celery/celery.service /usr/lib/systemd/system
scp $adminset_dir/install/server/celery/start_celery.sh $config_dir/celery/start_celery.sh
scp $adminset_dir/install/server/celery/beat.service /usr/lib/systemd/system
chmod +x $config_dir/celery/start_celery.sh
chkconfig celery on
chkconfig beat on
service celery start
service beat start
#
## 安装nginx
#echo "####install nginx####"
#yum install nginx -y
#chkconfig nginx on
#scp $adminset_dir/install/server/nginx/adminset.conf /etc/nginx/conf.d
#scp $adminset_dir/install/server/nginx/nginx.conf /etc/nginx
#service nginx start
#nginx -s reload
#
