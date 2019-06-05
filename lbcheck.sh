#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

paramswo=$(cat `ls /vagrant/*.sh | grep -v check` | grep -o 'without[^ ]*')
paramsw=$(cat `ls /vagrant/*.sh | grep -v check` | grep -o 'with-[^ ]*')
paramsadd=$(cat `ls /vagrant/*.sh | grep -v check` | grep -o 'add-module[^ ]*')

echo -e "${GREEN}Nginx built parameters:${NC}"
echo -e "$paramswo \n$paramsw \n$paramsadd"


user="vagrant"
nginx_user=`ps -ef | grep "nginx: master" | grep -v grep | awk '{print $1}'`
worker_procs=`cat /home/$user/nginx/conf/nginx.conf | grep worker_processes | awk '{print $2}'`
connections=`cat /home/$user/nginx/conf/nginx.conf | grep worker_connections | awk '{print $2}'`
port=`cat /home/$user/nginx/conf/vhosts/lb.conf  | grep listen | awk '{print $2}'`
server_name=`cat /home/$user/nginx/conf/vhosts/lb.conf  | grep server_name | grep -v return | awk '{print $2}'| uniq`
backends=`cat /home/$user/nginx/conf/upstreams/web.conf | grep server | awk '{print $2" "$3}'`


perms=`find /home/$user/nginx/ ! -user $user -printf '%p %u\n'`

if [ -z "$perms" ]
then
  echo -e "${GREEN}TRUE${NC} Nginx file permissions ${GREEN}OK${NC}"
else
  echo -e "${RED}FALSE${NC} Nginx file permissions ${RED}NOT OK${NC}"
fi


if [ -f /home/$user/nginx/sbin/nginx ]
then
  echo -e "${GREEN}TRUE${NC} Binary is on place"
else
  echo -e "${RED}FALSE${NC} Binary is on place"
fi

if [ -f /home/$user/nginx/conf/nginx.conf ]
then
  echo -e "${GREEN}TRUE${NC} Main conf is on place"
  echo -e "Worker processes: ${BLUE}${worker_procs//;}${NC}"
  echo -e "Connections per worker: ${BLUE}${connections//;}${NC}"
else
  echo -e "${RED}FALSE${NC} Main conf is on place"
fi

if [ -f /home/$user/nginx/conf/vhosts/lb.conf ]
then
  echo -e "${GREEN}TRUE${NC} LB conf is on place and named properly"
  echo -e "Binding port: ${BLUE}${port//;}${NC}"|tr '\n' ' '
  echo
  echo -e "Server name: ${BLUE}${server_name//;}${NC}"|tr '\n' ' '
  echo

else
  echo -e "${RED}FALSE${NC} LB conf is on place and named properly"
fi

if [ -f /home/$user/nginx/conf/upstreams/web.conf ]
then
  echo -e "${GREEN}TRUE${NC} Upsteams conf is on place and named properly"
  echo -e "Backends: ${BLUE}${backends//;}${NC}"|tr '\n' ' '
  echo

else
  echo -e "${RED}FALSE${NC} Upstreams conf is on place and named properly"
fi



if [ -f /home/$user/nginx/logs/error.log ]
then
  echo -e "${GREEN}TRUE${NC} Error log is on place"
else
  echo -e "${RED}FALSE${NC} Error log is on place"
fi


if [ -f /home/$user/nginx/logs/access.log ]
then
  echo -e "${GREEN}TRUE${NC} Access log is on place"
else
  echo -e "${RED}FALSE${NC} Access log is on place"
fi


if [ -f /home/$user/nginx/logs/nginx.pid ]
then
  echo -e "${GREEN}TRUE${NC} Pid file is on place"
else
  echo -e "${RED}FALSE${NC} Pid file is on place"
fi

if [ -z "$nginx_user" ]
then
  echo -e "${RED}FALSE${NC} Nginx is running"
else
  echo -e "${GREEN}TRUE${NC} Nginx is running"
  echo -e "${BLUE}${nginx_user^^}${NC} user for running process"
fi
