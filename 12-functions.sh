#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root user access"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo "$2 ... FAILURE"
        exit 1
    else
        echo "$2 ... SUCCESS"
    fi
}

apt install nginx -y
VALIDATE $? "Installing Nginx"

apt install mysql -y
VALIDATE $? "Installing Mysql"

apt install nodejs -y
VALIDATE $? "Installing nodejs"