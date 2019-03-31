#!/bin/sh
set -e

# deploy app
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
