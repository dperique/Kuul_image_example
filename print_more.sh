#!/bin/bash

echo "This script will do more stuff"
echo "  and print more stuff"

set -x
echo "I can ping something else on the Internet"
ping -c 5 www.amazon.com
set +x

echo "Then I can print my first parameter and do more: $1"
