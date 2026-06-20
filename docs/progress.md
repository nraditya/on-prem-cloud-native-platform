# Project Progress

## On-Premise Cloud-Native CI/CD and Monitoring Platform

This document records the implementation progress of the local on-premise DevOps and SRE portfolio project.

The platform runs on Windows 10 with Ubuntu WSL2, Docker Desktop, k3d Kubernetes, Terraform, Jenkins, Prometheus, Grafana, Bash, and Ansible.

---

## Project Status

**Current status: Completed**

The planned technical scope has been implemented:

* FastAPI application
* Automated application testing
* Docker containerization
* Non-root container execution
* Kubernetes deployment
* Kubernetes security hardening
* Terraform Infrastructure as Code
* Jenkins CI/CD pipeline
* Prometheus metrics collection
* Grafana dashboard
* Prometheus alert rules
* Bash automation
* Ansible validation
* Monitoring and alerting evidence

---

# Phase 1 — Application and Containerization

## Completed

* Created the CloudOps Status API using Python and FastAPI.
* Added the following endpoints:

  * `/`
  * `/health`
  * `/metrics`
  * `/simulate-load`
  * `/simulate-error`
* Added custom Prometheus metrics:

  * `cloudops_request_total`
  * `cloudops_error_total`
* Configured `/simulate-error` to return HTTP status `500`.
* Created the application dependency files.
* Created a Dockerfile for the FastAPI application.
* Built and tested the Docker image locally.
* Verified application health and Prometheus metrics using `curl`.

## Validation

```bash
curl -i http://localhost:8001/health
curl -s http://localhost:8001/metrics | head
curl -i http://localhost:8001/simulate-error
```

---

# Phase 2 — Kubernetes and Infrastructure as Code

## Completed

* Created the local k3d Kubernetes cluster:

  * Cluster name: `cloudops-cluster`
* Created the application namespace:

  * `cloudops`
* Created Kubernetes resources:

  * Namespace
  * Deployment
  * ClusterIP Service
* Configured two application replicas.
* Added readiness and liveness probes using `/health`.
* Imported the local Docker image into k3d.
* Verified both application Pods were running.
* Exposed the application locally using Kubernetes port-forward.
* Installed Terraform version `1.9.8`.
* Configured the Terraform Kubernetes provider.
* Used Terraform to manage:

  * Namespace
  * Deployment
  * Service
  * Health probes
  * Resource configuration
  * Security context
* Added Terraform `ignore_changes` for the Deployment image so Terraform does not revert images deployed by Jenkins.

## Validation

```bash
kubectl get nodes
kubectl get deployment,pods,service -n cloudops
terraform validate
terraform plan
terraform state list
terraform output
```

---

# Phase 3 — CI/CD, Testing, and Security Hardening

## Automated Testing

### Completed

* Created `tests/test_main.py`.
* Added five Pytest tests covering:

  * Root endpoint
  * Health endpoint
  * Metrics endpoint
  * Load simulation endpoint
  * Error simulation endpoint
* Added:

  * `app/requirements-dev.txt`
  * `app/__init__.py`
* Verified the complete test suite.

### Result

```text
5 passed
```

## Docker Non-Root Runtime

### Completed

* Created a dedicated application user.
* Configured the runtime container with:

```text
USER 10001:10001
```

* Verified the container runs as:

```text
uid=10001(appuser)
gid=10001(appgroup)
```

## Kubernetes Hardening

### Completed

Configured resource requests:

```text
CPU: 50m
Memory: 64Mi
```

Configured resource limits:

```text
CPU: 250m
Memory: 256Mi
```

Configured Kubernetes security controls:

```yaml
runAsNonRoot: true
runAsUser: 10001
runAsGroup: 10001
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities:
  drop:
    - ALL
```

Verified:

* Deployment reached `READY 2/2`.
* Both Pods were running.
* The application container used UID `10001`.
* Health checks remained successful.
* The read-only root filesystem did not break the application.

## Jenkins CI/CD

### Completed

The Jenkins pipeline contains these stages:

1. Checkout
2. Verify Tools
3. Build Docker Image
4. Test Application
5. Import Image to k3d
6. Deploy to Kubernetes
7. Health Check

The pipeline performs:

* GitHub repository checkout
* Tool validation
* Docker image build
* Non-root runtime verification
* Five automated Pytest tests
* Image import into k3d
* Kubernetes Deployment update
* Kubernetes rollout verification
* Application health verification

### Result

```text
Finished: SUCCESS
```

---

# Phase 4 — Monitoring and Alerting

## Monitoring Stack

### Completed

Installed the `kube-prometheus-stack` Helm chart in the `monitoring` namespace.

The monitoring stack includes:

* Prometheus
* Grafana
* Alertmanager
* Prometheus Operator
* kube-state-metrics
* Node Exporter

## ServiceMonitor

### Completed

Created:

```text
monitoring/cloudops-servicemonitor.yaml
```

Configuration:

* Target namespace: `cloudops`
* Application selector: `app=cloudops-api`
* Metrics path: `/metrics`
* Service port: `http`
* Scrape interval: `15s`

Verified that Prometheus discovered both application targets:

```text
2 / 2 up
```

## Grafana Dashboard

### Completed

Exported the final dashboard to:

```text
monitoring/grafana-dashboard.json
```

Dashboard panels include:

* CloudOps API Target Status
* Available Replicas
* Desired Replicas
* CloudOps API Request Rate
* CloudOps API Error Rate
* Total Simulated Errors
* CloudOps API CPU Usage
* CloudOps API Memory Usage
* FastAPI Process Memory

Main application queries:

```promql
sum(rate(cloudops_request_total[1m]))
```

```promql
sum(rate(cloudops_error_total[1m]))
```

```promql
sum(cloudops_error_total)
```

## Traffic Simulation

### Completed

Generated normal traffic to populate:

* Request Rate
* CPU Usage
* Memory Usage

Generated simulated HTTP 500 errors to populate:

* Error Rate
* Total Simulated Errors

Verified:

* Request Rate increased during traffic generation.
* Error Rate increased during simulated errors.
* Total Simulated Errors increased.
* Application replicas remained available.

## Prometheus Alert Rules

### Completed

Created:

```text
monitoring/cloudops-prometheusrule.yaml
```

Added two alerts.

### `CloudOpsAPITargetDown`

Purpose:

* Detects when Prometheus cannot scrape one or more application targets.
* Uses severity `critical`.
* Uses a one-minute pending period before firing.

### `CloudOpsAPIErrorActivity`

Purpose:

* Detects increases in `cloudops_error_total`.
* Uses severity `warning`.
* Evaluates error activity during the previous two minutes.

Verified:

* Both rules were loaded by Prometheus.
* Rule health was `OK`.
* `CloudOpsAPITargetDown` successfully reached `FIRING` during a controlled test.
* ServiceMonitor was restored to `/metrics`.
* Both targets returned to `UP`.

## Evidence

Final monitoring evidence is stored in:

```text
screenshots/phase-4-monitoring-alerting/
```

Files:

```text
01-grafana-cloudops-dashboard.png
02-prometheus-cloudops-targets-up.png
03-prometheus-cloudops-rules.png
04-alert-target-down-firing.png
05-kubernetes-monitoring-verification.png
```

---

# Phase 5 — Local Automation

## Bash Automation

### Completed

Created scripts for:

* Starting and validating the k3d cluster
* Application health checking
* Monitoring stack checking
* Opening Prometheus
* Opening Grafana
* Generating application traffic

Scripts are stored in:

```text
scripts/
```

## Ansible Validation

### Completed

Created a local Ansible playbook that validates:

* Docker
* kubectl
* k3d
* Helm
* Terraform
* Kubernetes nodes
* Application Pods
* Monitoring Pods

Files:

```text
ansible/inventory.ini
ansible/setup-local.yml
```

---

# Final Technical Validation

The final platform validation confirmed:

* Docker Desktop was accessible from Ubuntu WSL2.
* The k3d cluster was active.
* Both Kubernetes nodes were `Ready`.
* The CloudOps Deployment was `2/2`.
* Both application Pods were `Running`.
* The application Service had two active endpoints.
* The monitoring stack was running.
* Both Prometheus application targets were `UP`.
* Both Prometheus alert rules were loaded.
* The Grafana dashboard displayed application and infrastructure metrics.
* Jenkins completed automated tests and deployment successfully.
* Terraform state matched the managed Kubernetes resources.
* The Git working tree was clean after the Phase 4 commit.

---

# Project Outcome

The project demonstrates an end-to-end local DevOps and SRE workflow:

```text
FastAPI source code
→ Pytest automated testing
→ Docker image
→ Non-root container
→ Terraform-managed Kubernetes resources
→ Jenkins CI/CD deployment
→ Prometheus metrics
→ Grafana dashboard
→ Prometheus alerts
→ Bash and Ansible validation
```

The project is designed as a single-laptop on-premise learning platform. It applies production-oriented engineering practices, but it is not presented as a production-ready enterprise environment.

