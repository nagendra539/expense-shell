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

dnf module disable nodejs -y &>>${LOG_FILE}
VALIDATE $? "disabled the module "

dnf module enable nodejs:20 -y &>>${LOG_FILE}
VALIDATE $? "Enabled the NodeJs-20"

dnf install nodejs -y &>>${LOG_FILE}
VALIDATE $? "Installed the NodeJS-20"

useradd expense &>>${LOG_FILE}
VALIDATE $? "Expense User Created"

mkdir -p /app &>>${LOG_FILE}
VALIDATE $? "Creation of /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>${LOG_FILE}
cd /app
rm -rf *
unzip /tmp/backend.zip
VALIDATE $? "Un zip the content"