#!/bin/bash


yum install -y net-tools

if [[ ! -d /home/vagrant/nginx ]]; then
	mkdir -p /tmp/nginx
	cd /tmp/nginx/
	wget https://nginx.org/download/nginx-1.14.2.tar.gz
	tar xvf nginx-1.14.2.tar.gz
	yum install -y gcc gcc-c++ git
	git clone https://github.com/vozlt/nginx-module-vts.git
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.42.tar.gz
	tar xvf pcre-8.42.tar.gz 
	wget https://www.openssl.org/source/openssl-1.0.2q.tar.gz
	tar xvf openssl-1.0.2q.tar.gz 

	cd nginx-1.14.2

	./configure --prefix=/home/vagrant/nginx --sbin-path=/home/vagrant/nginx/sbin/nginx --conf-path=/home/vagrant/nginx/conf/nginx.conf --error-log-path=/home/vagrant/nginx/logs/error.log --http-log-path=/home/vagrant/nginx/logs/access.log --pid-path=/home/vagrant/nginx/logs/nginx.pid --user=vagrant --with-http_ssl_module --with-http_realip_module --add-module=../nginx-module-vts --with-pcre=../pcre-8.42 --with-openssl=../openssl-1.0.2q --without-http_gzip_module


	make 
	make install


fi


if [[ ! -f /etc/systemd/system/nginx.service ]]; then
cat << EOT >> /etc/systemd/system/nginx.service
	[Unit]
	Description=The NGINX HTTP and reverse proxy server
	After=network.target

	[Service]

	User=vagrant
	Group=vagrant
	Type=forking
	PIDFile=/home/vagrant/nginx/logs/nginx.pid
	ExecStartPre=/home/vagrant/nginx/sbin/nginx -t
	ExecStart=/home/vagrant/nginx/sbin/nginx
	ExecReload=/home/vagrant/nginx/sbin/nginx -s reload
	ExecStop=/bin/kill -s QUIT $MAINPID
	PrivateTmp=true

	[Install]
	WantedBy=multi-user.target
EOT
fi

if [[  -d /home/vagrant/nginx ]]; then
	cd /home/vagrant/nginx/
	tar xvf /vagrant/html.tar.gz 
	echo "admin:$(openssl passwd -crypt nginx)" >> /home/vagrant/nginx/conf/.htpass
fi

if [[ ! -d /home/vagrant/nginx/conf/vhosts/ ]]; then
	mkdir -p /home/vagrant/nginx/conf/vhosts/
fi

TYPE=$(hostname)
if [[ $TYPE  == "nginx.back"* ]]; then
	yes | cp  /vagrant/nginx.conf  /home/vagrant/nginx/conf/
	yes | cp  /vagrant/backend.conf  /home/vagrant/nginx/conf/vhosts/

elif [[ $TYPE  == "nginx.bal"* ]]; then
	sudo iptables -A PREROUTING -t nat -p tcp --dport 80 -j REDIRECT --to-ports 8080
	sudo iptables -A PREROUTING -t nat -p tcp --dport 443 -j REDIRECT --to-ports 8443
	yes | cp  /vagrant/nginx_bal.conf  /home/vagrant/nginx/conf/nginx.conf
	mkdir /home/vagrant/nginx/conf/upstreams	
cat << EOT >> /home/vagrant/nginx/conf/upstreams/web.conf
	upstream backend {
	}
EOT
    for ((i=$1;i>=1;i--)); do
		sed -i "1 a server 192.168.56.$((i+1)):8443;" /home/vagrant/nginx/conf/upstreams/web.conf
    done
	sed -i "2~2 s/\:8443\;/\:8443 weight=1\;/g" /home/vagrant/nginx/conf/upstreams/web.conf
	sed -i "3~2 s/\:8443\;/\:8443 weight=3\;/g" /home/vagrant/nginx/conf/upstreams/web.conf
 
cat << EOT >> /home/vagrant/nginx/conf/vhosts/lb.conf 
	server {
		listen   *:8080;
		server_name;
		return 301 https://\$server_name\$request_uri;
	}
	server {   
		listen   *:8443 ssl;
		server_name;
		ssl_certificate /home/vagrant/nginx/ssl/test.crt;
		ssl_certificate_key /home/vagrant/nginx/ssl/test.key;
		error_page  404              /404.html;
		proxy_intercept_errors on;
		location /status {
			vhost_traffic_status_display;
			vhost_traffic_status_display_format html;
			allow 192.168.56.1;
			deny all;
		}
		location / {
			proxy_pass http://backend;
		}
		location /404.html {
		}
	}   
EOT
	
	temp=$(hostname | sed 's/nginx.balancer//')
	sed -i "s/server_name\;/server_name 192.168.56.$((temp+100))\;/g" /home/vagrant/nginx/conf/vhosts/lb.conf  
    
    mkdir /home/vagrant/nginx/ssl
    cd /home/vagrant/nginx/ssl
	openssl genrsa -out test.key 2048
	openssl req -new -key test.key -out test.csr \
	-subj "/C=by/ST=minsk/L=p27/O=epam/OU=testlab/CN=dzmitry_yurchanka/emailAddress=dzmitry_yurchanka@epam.com"
	openssl x509 -req -days 365 -in test.csr -signkey test.key -out test.crt
	chmod 700 /home/vagrant/nginx/ssl
	chmod 600 /home/vagrant/nginx/ssl/*
	
fi

chown -R vagrant:vagrant /home/vagrant/nginx/ 
systemctl start nginx
systemctl enable nginx
