#!/bin/bash

set -e

echo "=== Checking monitoring namespace ==="
kubectl get ns monitoring

echo ""
echo "=== Checking monitoring pods ==="
kubectl get pods -n monitoring

echo ""
echo "=== Checking monitoring services ==="
kubectl get svc -n monitoring

echo ""
echo "=== Checking ServiceMonitor ==="
kubectl get servicemonitor -A

echo ""
echo "=== Checking Prometheus target resources ==="
kubectl get prometheus -n monitoring

echo ""
echo "Monitoring check completed."
