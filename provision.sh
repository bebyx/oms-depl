#!/bin/bash

sudo dnf install -y git wget @maven mariadb

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

mysql -u oms  -p"$DB_PASS" -h$DB_URL <<-EOF
CREATE DATABASE testdb DEFAULT CHARSET = utf8 COLLATE = utf8_unicode_ci;
CREATE DATABASE omsdb DEFAULT CHARSET = utf8 COLLATE = utf8_unicode_ci;
EOF

git clone -q https://github.com/bebyx/oms.git
sed -i "s|127.0.0.1|$DB_URL|"  ~/oms/src/test/resources/hibernate_test.cfg.xml
sed -i "s|>password<|>$DB_PASS<|"  ~/oms/src/test/resources/hibernate_test.cfg.xml
sed -i "s|localhost|$DB_URL|"  ~/oms/src/main/webapp/WEB-INF/hibernate.cfg.xml
sed -i "s|>password<|>$DB_PASS<|"  ~/oms/src/main/webapp/WEB-INF/hibernate.cfg.xml

mvn -f ~/oms/pom.xml clean package
sudo cp ~/oms/target/OMS.war /usr/local/tomcat9/webapps/
sudo chown tomcat:tomcat /usr/local/tomcat9/webapps/OMS.war

sudo systemctl restart tomcat.service
sleep 10
mysql -u oms -p"$DB_PASS" -h$DB_URL omsdb < oms/scripts/addDataMySql.sql
