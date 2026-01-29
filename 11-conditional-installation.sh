#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root user access"
    exit 1
fi

echo "Installing Nginx"
apt install nginx -y

if [ $? -ne 0 ]; then
    echo "Installing Nginx ... FAILURE"
    exit 1
else
    echo "Installing Nginx ... SUCCESS"
fi

apt install mysql -y

if [ $? -ne 0 ]; then
    echo "Installing MySQL ... FAILURE"
    exit 1
else
    echo "Installing MySQL ... SUCCESS"
fi

apt install nodejs -y

if [ $? -ne 0 ]; then
    echo "Installing nodejs ... FAILURE"
    exit 1
else
    echo "Installing nodejs ... SUCCESS"
fi