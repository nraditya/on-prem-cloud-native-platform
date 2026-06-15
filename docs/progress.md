# Project Progress

## Milestone 1 - FastAPI Application
Status: Completed

- Created Python FastAPI application
- Added health check endpoint
- Added Prometheus metrics endpoint
- Tested locally using curl

## Milestone 2 - Docker
Status: Completed

- Created Dockerfile
- Built Docker image
- Ran application as Docker container
- Tested /health endpoint from container

## Milestone 3 - Kubernetes
Status: Completed

- Created k3d Kubernetes cluster
- Deployed application to Kubernetes
- Created namespace, deployment, and service
- Ran 2 application replicas
- Tested application using kubectl port-forward

## Milestone 4 - Terraform IaC
Status: Completed

- Created Terraform Kubernetes provider configuration
- Provisioned namespace, deployment, and service using Terraform
- Verified resources using kubectl
- Tested /health endpoint after Terraform deployment

## Prometheus and Grafana Monitoring

Monitoring stack was installed using Helm with kube-prometheus-stack.

Completed:
- Created monitoring namespace.
- Installed Prometheus Operator, Prometheus, Alertmanager, kube-state-metrics, and Grafana.
- Created ServiceMonitor for cloudops-api-service.
- Verified that Prometheus can scrape the FastAPI /metrics endpoint.
- Created Grafana dashboard for CloudOps API monitoring.
- Monitored API target status, available replicas, desired replicas, CPU usage, memory usage, and FastAPI process memory.

Evidence:
- Prometheus target status: UP
- Grafana dashboard: CloudOps API Monitoring Dashboard
- Dashboard JSON exported to monitoring/grafana-dashboard.json
