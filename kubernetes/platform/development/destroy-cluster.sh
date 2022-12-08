#!/bin/sh

tilt down -f ../../applications/development/Tiltfile

echo "\n🏴️ Destroying Kubernetes cluster...\n"
minikube stop --profile polar
minikube delete --profile polar
echo "\n🏴️ Cluster destroyed\n"
