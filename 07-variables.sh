#!/bin/bash

#### Special Variables ####
echo "All args passed to script: $@"
echo "Number of vars passed to script: $#"
echo "Script name: $0"
echo "Present directory: $PWD"
echo "Who is running: $USER"
echo "Home directory of current user: $HOME"
echo "PID of this script: $$"
sleep 5 &
echo "PID of recently executed background process: $!"
echo "All args passed to script: $*"

## If a script is run as ./script.sh "hello world" "foo":
## for arg in "$@" loops twice: 1. "hello world", 2. "foo".
## for arg in "$*" loops once: 1. "hello world foo".