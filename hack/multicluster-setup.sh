#!/bin/bash

kind create cluster --name hub
kind create cluster --name cluster1
kind create cluster --name cluster2

kubectl config use-context kind-hub
# kubectl --context kind-hub label node hub-control-plane node.kubernetes.io/exclude-from-external-load-balancers-
bash integrations/database/postgresql/install.sh
kubectl --context kind-hub apply -f - <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: lb-service-local
  namespace: postgresql
spec:
  type: NodePort
  externalTrafficPolicy: Local
  selector:
    cnpg.io/cluster: kubearchive
    cnpg.io/instanceRole: primary
  ports:
    - protocol: TCP
      port: 5432
      nodePort: 30000
EOF

kubectl --context kind-hub apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.2/cert-manager.yaml
kubectl --context kind-cluster1 apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.2/cert-manager.yaml
kubectl --context kind-cluster2 apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.2/cert-manager.yaml

export KO_DOCKER_REPO="kind.local"
export KIND_CLUSTER_NAME=cluster1
kubectl config use-context kind-cluster1
bash hack/kubearchive-install.sh

kubectl config use-context kind-cluster2
export KIND_CLUSTER_NAME=cluster2
bash hack/kubearchive-install.sh

kubectl --context kind-cluster1 patch secret -n kubearchive kubearchive-database-credentials -p='{"stringData":{"DATABASE_PASSWORD": "Dat!abas]3Pass*w0rd", "DATABASE_URL": "hub-control-plane", "DATABASE_PORT": "30000"}}' -v=1
kubectl --context kind-cluster2 patch secret -n kubearchive kubearchive-database-credentials -p='{"stringData":{"DATABASE_PASSWORD": "Dat!abas]3Pass*w0rd", "DATABASE_URL": "hub-control-plane", "DATABASE_PORT": "30000"}}' -v=1

kubectl --context kind-cluster2 patch -n kubearchive jobs.batch kubearchive-schema-migration --patch '{"spec": {"suspend": false}}'
