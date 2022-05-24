#!/bin/sh

# Intended to be run within Dockerfile
find /etc/krakend/config/settings -type d -not -path /etc/krakend/config/settings/shared -exec cp /etc/krakend/config/settings/shared/* {} \;