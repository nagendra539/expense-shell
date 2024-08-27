#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -F1 )
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="${LOGS_FOLDER}/${SCRIPT_NAME}-${TIME_STAMP}.log"
mkdir -p ${LOGS_FOLDER}
USERID=$(id -u)

CHECKROOT(){
    if [ ${USERID} -ne 0 ]
    then
        echo " Please run the suite with root user"
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo "install of $2 was failed, Please check the error" &>>${LOG_FILE}
        exit 1
    else
        echo "install of $2 was success" &>>${LOG_FILE}
    fi
}

CHECKROOT
dnf install  mysql-server -y &>>${LOG_FILE} 
VALIDATE $? "mysql-server"

systemctl enable mysqld &>>${LOG_FILE}
VALIDATE $? "mysql-server" 

systemctl statrt mysqld &>>${LOG_FILE}
VALIDATE $? "mysql-server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "mysql-server"
