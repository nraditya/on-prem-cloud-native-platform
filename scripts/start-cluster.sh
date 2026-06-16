#!/bin/bash

set -e

CLUSTER_NAME="cloudops-cluster"

echo "=== Starting k3d cluster: $CLUSTER_NAME ==="
k3d cluster start $CLUSTER_NAME || true

echo ""
echo "=== Switching kubeconfig context ==="
k3d kubeconfig merge $CLUSTER_NAME --kubeconfig-switch-context

echo ""
echo "=== Checking Kubernetes nodes ==="
kubectl get nodes

echo ""
echo "=== Checking CloudOps API pods ==="
kubectl get pods -n cloudops

echo ""
echo "=== Checking CloudOps API service ==="
kubectl get svc -n cloudops

echo ""
echo "=== Checking current deployment image ==="
kubectl describe deployment cloudops-api -n cloudops | grep Image

echo ""
echo "Cluster and application check completed."
