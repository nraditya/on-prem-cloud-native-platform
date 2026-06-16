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

echo "=== Starting port-forward to CloudOps API ==="
kubectl port-forward -n $NAMESPACE svc/$SERVICE_NAME $LOCAL_PORT:$SERVICE_PORT > /tmp/cloudops-traffic-port-forward.log 2>&1 &
PF_PID=$!

sleep 5

echo ""
echo "=== Generating traffic ==="

for i in {1..10}; do
  echo "Request $i: /health"
  curl -s http://localhost:$LOCAL_PORT/health
  echo ""
  sleep 1
done

for i in {1..5}; do
  echo "Request $i: /simulate-load"
  curl -s http://localhost:$LOCAL_PORT/simulate-load || true
  echo ""
  sleep 1
done

for i in {1..3}; do
  echo "Request $i: /simulate-error"
  curl -s http://localhost:$LOCAL_PORT/simulate-error || true
  echo ""
  sleep 1
done

echo ""
echo "Traffic generation completed."
