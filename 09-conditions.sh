#!/bin/bash

num=100

if [ "$num" -gt 20 ]; then
  echo "Given number is greater than 20"
elif [ "$num" -eq 20 ]; then
  echo "Given number is equal to 20"
else
  echo "Given number is less than 20"
fi