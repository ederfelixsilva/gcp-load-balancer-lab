#!/bin/bash

gcloud compute instance-templates create lb-backend-template \
  --machine-type=e2-medium \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --tags=allow-health-check \
  --metadata-from-file startup-script=./startup.sh