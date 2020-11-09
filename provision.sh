#!/bin/bash

sudo dnf install -y git wget @maven

git clone https://github.com/bebyx/oms.git

sudo bash -c 'cat  << EOF > /etc/profile.d/maven.sh
export JAVA_HOME=/usr/lib/jvm/jre-openjdk
export JRE_HOME=/usr/lib/jvm/jre-openjdk
export M2_HOME=/opt/maven
export MAVEN_HOME=/opt/maven
export PATH=${M2_HOME}/bin:${PATH}
EOF'
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

sudo wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.39/bin/apache-tomcat-9.0.39.tar.gz -P /usr/local/
sudo tar -xvf /usr/local/apache-tomcat-9.0.39.tar.gz -C /usr/local/
sudo mv /usr/local/apache-tomcat-9.0.39 /usr/local/tomcat9

sudo sed -i -e "s|8080|8181|g" /usr/local/tomcat9/conf/server.xml

sudo useradd -r tomcat
sudo chown -R tomcat:tomcat /usr/local/tomcat9

sudo bash -c 'cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Server
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=CATALINA_PID=/usr/local/tomcat9/temp/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat9
Environment=CATALINA_BASE=/usr/local/tomcat9

ExecStart=/usr/local/tomcat9/bin/catalina.sh start
ExecStop=/usr/local/tomcat9/bin/catalina.sh stop

RestartSec=10
Restart=always
[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl start tomcat.service
sudo systemctl enable tomcat.service
