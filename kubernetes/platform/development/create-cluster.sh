#!/bin/sh

echo "\n📦 Initializing Kubernetes cluster...\n"
minikube start --cpus 2 --memory 4g --driver docker --profile polar

echo "\n🔌 Enabling NGINX Ingress Controller...\n"
minikube addons enable ingress --profile polar
sleep 30

echo "\n📦 Deploying Keycloak..."
# Pre-pull Keycloak image to avoid timeouts - see https://github.com/kubernetes/minikube/issues/14806
minikube --profile polar ssh docker pull quay.io/keycloak/keycloak:19.0
minikube kubectl --profile polar -- apply -f services/keycloak-config.yml
minikube kubectl --profile polar -- apply -f services/keycloak.yml
sleep 5

echo "\n⌛ Waiting for Keycloak to be deployed..."
while [ $(minikube kubectl --profile polar -- get pod -l app=polar-keycloak | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Keycloak to be ready..."
minikube kubectl --profile polar -- wait \
  --for=condition=ready pod \
  --selector=app=polar-keycloak \
  --timeout=300s

echo "\n📦 Deploying PostgreSQL..."
minikube kubectl --profile polar -- apply -f services/postgresql.yml

echo "\n⌛ Waiting for PostgreSQL to be deployed..."
while [ $(minikube kubectl --profile polar -- get pod -l db=polar-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for PostgreSQL to be ready..."
minikube kubectl --profile polar -- wait \
  --for=condition=ready pod \
  --selector=db=polar-postgres \
  --timeout=180s

echo "\n📦 Deploying Redis..."
minikube kubectl --profile polar -- apply -f services/redis.yml
sleep 5

echo "\n⌛ Waiting for Redis to be deployed..."
while [ $(minikube kubectl --profile polar -- get pod -l db=polar-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Redis to be ready..."
minikube kubectl --profile polar -- wait \
  --for=condition=ready pod \
  --selector=db=polar-redis \
  --timeout=180s

echo "\n📦 Deploying RabbitMQ..."
minikube kubectl --profile polar -- apply -f services/rabbitmq.yml
sleep 5

echo "\n⌛ Waiting for RabbitMQ to be deployed..."
while [ $(minikube kubectl --profile polar -- get pod -l db=polar-rabbitmq | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for RabbitMQ to be ready..."
minikube kubectl --profile polar -- wait \
  --for=condition=ready pod \
  --selector=db=polar-rabbitmq \
  --timeout=180s

echo "\n📦 Deploying Polar UI..."
minikube kubectl --profile polar -- apply -f services/polar-ui.yml
sleep 5

echo "\n⌛ Waiting for Polar UI to be deployed..."
while [ $(minikube kubectl --profile polar -- get pod -l app=polar-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Polar UI to be ready..."
minikube kubectl --profile polar -- wait \
  --for=condition=ready pod \
  --selector=app=polar-ui \
  --timeout=180s

echo "\n⛵ Happy Sailing!\n"

# tilt up -f ../../applications/development/Tiltfile
