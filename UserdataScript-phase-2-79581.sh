#!/bin/bash -xe
apt update -y
apt install nodejs unzip wget npm mysql-server git -y

# Re-enable mysql_native_password auth plugin for MySQL 8.x/8.4 compatibility
mysql_native_password_fix() {
    if mysql --version 2>/dev/null | grep -q "8\.[4-9]"; then
        echo "[mysqld]" >> /etc/mysql/mysql.conf.d/mysqld.cnf
        echo "mysql_native_password=ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf
        service mysql restart
    fi
}
mysql_native_password_fix

git clone https://github.com/JDeBo/is311-final-lab.git /home/ubuntu/app
cd /home/ubuntu/app/resources/codebase_partner
npm install aws aws-sdk
mysql -u root -e "CREATE USER 'nodeapp' IDENTIFIED WITH mysql_native_password BY 'student12'";
mysql -u root -e "GRANT all privileges on *.* to 'nodeapp'@'%';"
mysql -u root -e "CREATE DATABASE STUDENTS;"
mysql -u root -e "USE STUDENTS; CREATE TABLE students(
            id INT NOT NULL AUTO_INCREMENT,
            name VARCHAR(255) NOT NULL,
            address VARCHAR(255) NOT NULL,
            city VARCHAR(255) NOT NULL,
            state VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            phone VARCHAR(100) NOT NULL,
            PRIMARY KEY ( id ));"
sed -i 's/.*bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl enable mysql
service mysql restart
export APP_DB_HOST=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export APP_DB_USER=nodeapp
export APP_DB_PASSWORD=student12
export APP_DB_NAME=STUDENTS
export APP_PORT=80
npm start &
echo "#!/bin/bash -xe
cd /home/ubuntu/app/resources/codebase_partner
export APP_DB_HOST=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
export APP_DB_USER=nodeapp
export APP_DB_PASSWORD=student12
export APP_DB_NAME=STUDENTS
export APP_PORT=80
npm start" > /etc/rc.local
chmod +x /etc/rc.local
