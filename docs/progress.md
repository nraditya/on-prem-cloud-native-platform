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

## Bash and Ansible Automation

Completed:
- Created Bash scripts to start the k3d cluster, check application health, verify monitoring resources, open Prometheus, open Grafana, and generate API traffic.
- Created Ansible inventory for local automation.
- Created Ansible playbook to validate Docker, kubectl, k3d, Helm, Terraform, Kubernetes nodes, CloudOps API pods, and monitoring pods.
- Verified that automation scripts can be executed from the project repository.

Scripts:
- scripts/start-cluster.sh
- scripts/health-check.sh
- scripts/check-monitoring.sh
- scripts/open-prometheus.sh
- scripts/open-grafana.sh
- scripts/generate-traffic.sh

Ansible:
- ansible/inventory.ini
- ansible/setup-local.yml
