#!/bin/bash

# Get the Roku device IP address and password from the .env file
source .envvironment variable
export ROKU_IP_ADDRESS=$ROKU_IP_ADDRESS
export ROKU_PASSWORD=$ROKU_PASSWORD

# Enable running tests if necessary
if [ "$1" = "tests" ]; then
    # If it is, set the ROKU_RUN_TESTS environment variable to true
    export ROKU_RUN_TESTS=true
fi

# Deploy to the Roku device
node scripts/deploy.js

# Disable the ctrl+c interrupt so it can be used to access the BrightScript console via telnet
trap '' INT

# Connect to the Roku device using telnet
# To exit the telnet session, press ctrl+] and then type "quit" and press enter
telnet $ROKU_IP_ADDRESS 8085

# Re-enable the default interrupt signal handling
trap - INT