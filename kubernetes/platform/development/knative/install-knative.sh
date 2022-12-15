#!/bin/sh

echo "\n📦 Installing Knative CRDs..."
minikube kubectl --profile knative -- apply -f https://github.com/knative/serving/releases/download/knative-v1.7.0/serving-crds.yaml

echo "\n📦 Installing Knative Serving..."
minikube kubectl --profile knative -- apply -f https://github.com/knative/serving/releases/download/knative-v1.7.0/serving-core.yaml

echo "\n📦 Installing Kourier Ingress..."
minikube kubectl --profile knative -- apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.7.0/kourier.yaml

minikube kubectl --profile knative -- patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

echo "\n📦 Configuring DNS..."
minikube kubectl --profile knative -- patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"127.0.0.1.sslip.io":""}}'
minikube kubectl --profile knative -- apply -f https://github.com/knative/serving/releases/download/knative-v1.7.0/serving-default-domain.yaml

echo "\n✅ Knative successfully installed!\n"
