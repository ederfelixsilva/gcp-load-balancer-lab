#!/bin/bash

gcloud compute firewall-rules create www-firewall-network-lb \
  --allow tcp:80 \
  --target-tags=network-lb-tag \
  --network=default