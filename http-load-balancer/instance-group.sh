#!/bin/bash

ZONE="europe-west1-d"

gcloud compute instance-groups managed create lb-backend-group \
  --template=lb-backend-template \
  --size=2 \
  --zone=$ZONE

# Habilitar porta HTTP no grupo
gcloud compute instance-groups managed set-named-ports lb-backend-group \
  --zone=$ZONE \
  --named-ports=http:80