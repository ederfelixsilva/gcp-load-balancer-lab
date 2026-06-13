#!/bin/bash

REGION="europe-west1"
INSTANCES_ZONE="europe-west1-d"

# 1. Criar IP externo estático
gcloud compute addresses create network-lb-ip-1 \
  --region=$REGION

# 2. Criar target pool
gcloud compute target-pools create www-pool \
  --region=$REGION

# 3. Adicionar instâncias no target pool
gcloud compute target-pools add-instances www-pool \
  --instances=web1,web2,web3 \
  --instances-zone=$INSTANCES_ZONE

# 4. Criar forwarding rule (porta 80)
gcloud compute forwarding-rules create www-rule \
  --region=$REGION \
  --ports=80 \
  --address=network-lb-ip-1 \
  --target-pool=www-pool

# 5. Mostrar IP final
echo "Network Load Balancer IP:"
gcloud compute addresses describe network-lb-ip-1 \
  --region=$REGION \
  --format="get(address)"