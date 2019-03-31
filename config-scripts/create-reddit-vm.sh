#!/bin/sh

gcloud compute instances create reddit-full-app \
--image-family reddit-full \
--tags puma-server \
--restart-on-failure
