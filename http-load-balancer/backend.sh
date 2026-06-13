#!/bin/bash

# Criar health check
gcloud compute health-checks create http http-basic-check \
  --port 80

# Criar backend service global
gcloud compute backend-services create lb-backend-service \
  --protocol=HTTP \
  --health-checks=http-basic-check \
  --global

# Adicionar MIG ao backend
gcloud compute backend-services add-backend lb-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone=europe-west1-d \
  --global