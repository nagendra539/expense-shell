#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
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
        echo "$2 was failed, Please check the error" &>>${LOG_FILE}
        exit 1
    else
        echo "$2 was success" &>>${LOG_FILE}
    fi
}

CHECKROOT

dnf install nginx -y &>>${LOG_FILE}
VALIDATE $? "install nginx"

systemctl enable nginx &>>${LOG_FILE}
VALIDATE $? "enabled the nginx"

systemctl start nginx &>>${LOG_FILE}
VALIDATE $? "nginx"

rm -rf /usr/share/nginx/html/* &>>${LOG_FILE}
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>${LOG_FILE}
cd /usr/share/nginx/html &>>${LOG_FILE}
unzip /tmp/frontend.zip &>>${LOG_FILE}
VALIDATE $? "unzip the FE"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>${LOG_FILE}
VALIDATE $? "copied the expense.conf"

systemctl restart nginx  &>>${LOG_FILE}
VALIDATE $? "restarted the nginx"
