# On-Premise Cloud-Native CI/CD and Monitoring Platform

A self-hosted DevOps/SRE portfolio project running on a Windows 10 laptop with Ubuntu WSL2.

This project demonstrates application containerization, Kubernetes deployment, Infrastructure as Code, CI/CD automation, monitoring, and local infrastructure automation without using paid cloud services.

## Project Overview

The project uses a Python FastAPI application called **CloudOps Status API**.

The application is:

- Containerized using Docker
- Deployed to a k3d Kubernetes cluster
- Provisioned using Terraform
- Automatically built and deployed using Jenkins
- Monitored using Prometheus and Grafana
- Automated using Bash and Ansible

## Architecture

```text
Windows 10
└── Ubuntu WSL2
    ├── Docker Desktop
    │   └── k3d Kubernetes Cluster
    │       ├── CloudOps FastAPI Application
    │       ├── Prometheus
    │       └── Grafana
    ├── Jenkins CI/CD
    ├── Terraform
    ├── Bash Scripts
    └── Ansible
```

## Technology Stack

| Area | Technology |
|---|---|
| Application | Python FastAPI |
| Container | Docker |
| Kubernetes | k3d / k3s |
| CI/CD | Jenkins |
| Infrastructure as Code | Terraform |
| Monitoring | Prometheus |
| Dashboard | Grafana |
| Package Manager | Helm |
| Automation | Bash and Ansible |
| Environment | Windows 10 and Ubuntu WSL2 |

## Application Endpoints

| Endpoint | Function |
|---|---|
| `/` | Shows basic application information |
| `/health` | Application health check |
| `/metrics` | Prometheus metrics |
| `/simulate-load` | Simulates application load |
| `/simulate-error` | Simulates an application error |

## Repository Structure

```text
.
├── app/
├── kubernetes/
├── terraform/
├── jenkins/
├── monitoring/
├── scripts/
├── ansible/
├── docs/
└── README.md
```

## How to Run

### Start the Kubernetes cluster

```bash
./scripts/start-cluster.sh
```

### Check the application

```bash
./scripts/health-check.sh
```

### Check the monitoring stack

```bash
./scripts/check-monitoring.sh
```

### Open Prometheus

```bash
./scripts/open-prometheus.sh
```

Prometheus targets:

```text
http://localhost:9091/targets
```

### Open Grafana

```bash
./scripts/open-grafana.sh
```

Grafana:

```text
http://localhost:3000
```

### Generate application traffic

```bash
./scripts/generate-traffic.sh
```

### Run the Ansible environment check

```bash
ansible-playbook -i ansible/inventory.ini ansible/setup-local.yml
```

## CI/CD Workflow

The Jenkins pipeline performs the following process:

1. Clones the source code from GitHub
2. Builds a Docker image
3. Loads the image into the k3d cluster
4. Updates the Kubernetes deployment
5. Verifies the deployed application

Example deployed image:

```text
cloudops-status-api:jenkins-2
```

Verify the deployed image:

```bash
kubectl describe deployment cloudops-api -n cloudops | grep Image
```

## Monitoring

Prometheus collects metrics from the FastAPI `/metrics` endpoint through a Kubernetes `ServiceMonitor`.

The Grafana dashboard displays:

- Application target status
- Available replicas
- Desired replicas
- CPU usage
- Memory usage
- FastAPI process memory

Prometheus validation query:

```promql
up{namespace="cloudops"}
```

## Project Status

Completed:

- FastAPI application
- Docker containerization
- Kubernetes deployment
- Terraform Infrastructure as Code
- Jenkins CI/CD pipeline
- Prometheus monitoring
- Grafana dashboard
- Bash automation
- Ansible automation
