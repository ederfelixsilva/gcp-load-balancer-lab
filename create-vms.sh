#!/bin/bash

REGION="europe-west1"
ZONE="europe-west1-d"

for i in 1 2 3
do
  gcloud compute instances create web$i \
    --zone=$ZONE \
    --machine-type=e2-small \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --tags=network-lb-tag \
    --metadata-from-file startup-script=startup.sh
done
