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
admin_file=`cat /home/$user/nginx/conf/.*[A-Za-z]`
worker_procs=`cat /home/$user/nginx/conf/nginx.conf | grep worker_processes | awk '{print $2}'`
connections=`cat /home/$user/nginx/conf/nginx.conf | grep worker_connections | awk '{print $2}'`
port=`cat /home/$user/nginx/conf/vhosts/backend.conf  | grep listen | awk '{print $2}'`
header=`cat /home/$user/nginx/conf/vhosts/backend.conf | grep add_header | awk '{print $3}' | uniq`
allowed=`cat /home/$user/nginx/conf/vhosts/backend.conf  | grep allow | awk '{print $2}'`
denied=`cat /home/$user/nginx/conf/vhosts/backend.conf  | grep deny | awk '{print $2}'`

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
  echo -e "Allowed IP: ${BLUE}${allowed//;}${NC}"
  echo -e "Denied IP: ${BLUE}${denied//;}${NC}"


else
  echo -e "${RED}FALSE${NC} Main conf is on place"
fi

if [ -f /home/$user/nginx/conf/vhosts/backend.conf ]
then
  echo -e "${GREEN}TRUE${NC} Backend conf is on place and named properly"
  echo -e "Binding port: ${BLUE}${port//;}${NC}"
  echo -e "Header: ${BLUE}${header//;}${NC}"


else
  echo -e "${RED}FALSE${NC} Backend conf is on place and named properly"
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



if [ -z "$admin_file" ]
then
  echo -e "${RED}FALSE${NC} Admin file is on place"
else
  echo -e "${GREEN}TRUE${NC} ADMIN FILE content: ${admin_file}"
fi

