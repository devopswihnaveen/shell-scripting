#!/bin/bash

# Silent input for sensitive data

read -sp "Enter username: " USERNAME
echo
read -sp "Enter password: " PASSWORD
echo
read -sp "Enter API token: " API_TOKEN
echo

echo "Credentials captured securely."

# Demo output (never print real secrets in production)
echo "Username entered successfully."
echo "Password length: ${#PASSWORD}"
echo "API token length: ${#API_TOKEN}"
echo "Sensitive data handled securely."