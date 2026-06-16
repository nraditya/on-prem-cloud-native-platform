#!/bin/bash

set -e

LOCAL_PORT="${1:-3000}"

echo "=== Grafana Login Information ==="
echo "Username: admin"
echo -n "Password: "
kubectl get secret prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
echo ""

echo ""
echo "Grafana URL:"
echo "http://localhost:$LOCAL_PORT"
echo ""
echo "Starting port-forward..."
echo "Press CTRL + C to stop."

kubectl port-forward -n monitoring svc/prometheus-stack-grafana $LOCAL_PORT:80
