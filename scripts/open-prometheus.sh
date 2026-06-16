#!/bin/bash

set -e

LOCAL_PORT="${1:-9091}"

echo "=== Opening Prometheus ==="
echo "Prometheus URL:"
echo "http://localhost:$LOCAL_PORT"
echo ""
echo "Targets page:"
echo "http://localhost:$LOCAL_PORT/targets"
echo ""
echo "Starting port-forward..."
echo "Press CTRL + C to stop."

kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus $LOCAL_PORT:9090
