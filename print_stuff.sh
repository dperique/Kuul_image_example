#!/bin/bash

echo "This script will do stuff"
echo "  and print stuff"

set -x
echo "I can ping something on the Internet"
ping -c 5 www.google.com
set +x
