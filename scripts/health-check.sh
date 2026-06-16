#!/bin/bash

set -e

NAMESPACE="cloudops"
SERVICE_NAME="cloudops-api-service"
LOCAL_PORT="8001"
SERVICE_PORT="80"

cleanup() {
  echo ""
  echo "Stopping port-forward..."
  if [ -n "$PF_PID" ]; then
    kill "$PF_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT

echo "=== Checking CloudOps API resources ==="
kubectl get pods -n $NAMESPACE
kubectl get svc -n $NAMESPACE

echo ""
echo "=== Starting port-forward $LOCAL_PORT:$SERVICE_PORT ==="
kubectl port-forward -n $NAMESPACE svc/$SERVICE_NAME $LOCAL_PORT:$SERVICE_PORT > /tmp/cloudops-api-port-forward.log 2>&1 &
PF_PID=$!

sleep 5

echo ""
echo "=== Testing /health endpoint ==="
curl -f http://localhost:$LOCAL_PORT/health
echo ""

echo ""
echo "=== Testing /metrics endpoint ==="
curl -f http://localhost:$LOCAL_PORT/metrics | head

echo ""
echo "Health check completed successfully."
