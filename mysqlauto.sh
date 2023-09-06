if [ -z "$1"]; then
  echo input argument password is needed
  exit
fi

ROBOSHOP_MYSQL_PASSWORD=$1

curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
if [$? -eq 0 ]; then
  echo SUCESS
else
  echo FAILURE
  exit
fi

echo disable mysql 8 version repo
dnf module disable mysql -y
if [$? -eq 0 ]; then
  echo SUCESS
else
  echo FAILURE
  exit
fi

echo install MySQL
yum install mysql-community-server -y
if [$? -eq 0 ]; then
  echo SUCESS
else
  echo FAILURE
  exit
fi

echo Enable MySQL Service
systemctl enable mysqld
if [$? -eq 0 ]; then
  echo SUCESS
else
  echo FAILURE
  exit
fi

echo restart MySQL Service
systemctl restart mysqld
if [$? -eq 0 ]; then
  echo SUCESS
else
  echo FAILURE
  exit
fi

echo show databases | mysql -uroot -pROBOSHOP_MYSQL_PASSWORD
if  [ $? -ne 0 ]
then
 echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'ROBOSHOP_MYSQL_PASSWORD';" > /tmp/root-pass-sql
 DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
 cat /tmp/root-pass-sql | mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}"
fi