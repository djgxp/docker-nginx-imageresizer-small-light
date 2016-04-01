#!/bin/bash

echo "Starting SSHD..."
/usr/sbin/sshd

echo "Starting Nginx..."
/usr/sbin/nginx -g 'daemon off;'