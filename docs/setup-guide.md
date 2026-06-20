# Fresh Clone Setup Guide

## On-Premise Cloud-Native CI/CD and Monitoring Platform

This guide explains how to prepare the local environment and run the complete platform from a fresh Git clone.

The platform is designed for:

* Windows 10
* Ubuntu WSL2
* Docker Desktop
* Local k3d Kubernetes
* Terraform
* Jenkins
* Prometheus
* Grafana
* Ansible

The project does not require a paid public cloud account.

---

# 1. Environment Requirements

Install and configure the following tools before cloning the repository:

| Tool                          | Purpose                         |
| ----------------------------- | ------------------------------- |
| Windows Subsystem for Linux 2 | Linux development environment   |
| Ubuntu WSL2                   | Main terminal environment       |
| Docker Desktop                | Container runtime               |
| Git                           | Repository management           |
| Python 3                      | FastAPI application and testing |
| kubectl                       | Kubernetes administration       |
| k3d                           | Local Kubernetes cluster        |
| Helm                          | Kubernetes package manager      |
| Terraform                     | Infrastructure as Code          |
| Java                          | Jenkins runtime                 |
| Jenkins WAR                   | Local CI/CD server              |
| Ansible                       | Environment validation          |

Recommended Java version:

```text
Java 17 or newer
```

Recommended Terraform version:

```text
Terraform 1.9.x
```

---

# 2. Verify the Required Tools

Open Ubuntu WSL2 and run:

```bash
docker --version
git --version
python3 --version
kubectl version --client
k3d version
helm version
terraform version
java -version
ansible --version
```

Docker Desktop must be running before Docker and k3d commands are used.

Verify Docker access:

```bash
docker info
```

If Docker cannot be accessed from WSL2, open Docker Desktop and verify that WSL integration is enabled for the Ubuntu distribution.

---

# 3. Clone the Repository

Move to the desired working directory:

```bash
mkdir -p ~/projects
cd ~/projects
```

Clone the repository:

```bash
git clone https://github.com/nraditya/on-prem-cloud-native-platform.git
```

Enter the project:

```bash
cd on-prem-cloud-native-platform
```

Verify the Git branch:

```bash
git branch --show-current
git status
```

Expected branch:

```text
main
```

---

# 4. Run Automated Tests

Create a Python virtual environment:

```bash
python3 -m venv .venv
```

Activate it:

```bash
source .venv/bin/activate
```

Upgrade pip:

```bash
python -m pip install --upgrade pip
```

Install application dependencies:

```bash
pip install -r app/requirements.txt
```

Install development and testing dependencies:

```bash
pip install -r app/requirements-dev.txt
```

Run the automated tests:

```bash
python -m pytest -v
```

Expected result:

```text
5 passed
```

Deactivate the environment when it is no longer needed:

```bash
deactivate
```

---

# 5. Create the k3d Kubernetes Cluster

Check whether the cluster already exists:

```bash
k3d cluster list
```

Create the cluster when `cloudops-cluster` does not exist:

```bash
k3d cluster create cloudops-cluster \
  --servers 1 \
  --agents 1
```

Verify the Kubernetes context:

```bash
kubectl config current-context
```

Expected context:

```text
k3d-cloudops-cluster
```

Verify the nodes:

```bash
kubectl get nodes -o wide
```

Expected condition:

```text
STATUS: Ready
```

The cluster contains:

* One k3s server node
* One k3s agent node

---

# 6. Build the Local Docker Image

Build the application image:

```bash
docker build \
  -t cloudops-status-api:local \
  app/
```

Verify the image:

```bash
docker image ls cloudops-status-api
```

Verify the container runtime user:

```bash
docker run --rm \
  cloudops-status-api:local \
  id
```

Expected result:

```text
uid=10001(appuser) gid=10001(appgroup)
```

The container must not run as root.

---

# 7. Import the Image into k3d

The Kubernetes Deployment uses a local image with `imagePullPolicy: Never`.

Import the image into the cluster:

```bash
k3d image import \
  cloudops-status-api:local \
  --cluster cloudops-cluster
```

Verify the cluster remains available:

```bash
kubectl get nodes
```

---

# 8. Provision Kubernetes Resources with Terraform

Enter the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the execution plan:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

Type:

```text
yes
```

when Terraform requests confirmation.

Terraform creates or manages:

* `cloudops` namespace
* CloudOps API Deployment
* CloudOps API Service
* Two application replicas
* Health probes
* Resource requests and limits
* Kubernetes security context

Return to the repository root:

```bash
cd ..
```

---

# 9. Verify the Kubernetes Application

Check the application resources:

```bash
kubectl get deployment,pods,service -n cloudops
```

Expected Deployment condition:

```text
READY: 2/2
AVAILABLE: 2
```

Both application Pods should have:

```text
STATUS: Running
READY: 1/1
```

Check the rollout:

```bash
kubectl rollout status \
  deployment/cloudops-api \
  -n cloudops
```

Check the Service endpoints:

```bash
kubectl get endpointslice -n cloudops
```

---

# 10. Access the Application

Open a dedicated WSL terminal and run:

```bash
kubectl port-forward \
  -n cloudops \
  service/cloudops-api-service \
  8001:80
```

Keep this terminal running.

Open another WSL terminal for verification.

Health endpoint:

```bash
curl -i http://localhost:8001/health
```

Expected status:

```text
HTTP/1.1 200 OK
```

Root endpoint:

```bash
curl -s http://localhost:8001/
```

Metrics endpoint:

```bash
curl -s http://localhost:8001/metrics | head -n 20
```

Error simulation:

```bash
curl -i http://localhost:8001/simulate-error
```

Expected status:

```text
HTTP/1.1 500 Internal Server Error
```

---

# 11. Install the Monitoring Stack

Add the Prometheus Community Helm repository:

```bash
helm repo add \
  prometheus-community \
  https://prometheus-community.github.io/helm-charts
```

Update Helm repositories:

```bash
helm repo update
```

Install the monitoring stack:

```bash
helm upgrade --install \
  prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

Wait until the monitoring Pods are ready:

```bash
kubectl get pods -n monitoring
```

Monitor the rollout:

```bash
kubectl get pods -n monitoring -w
```

Press `Ctrl+C` after all main monitoring Pods are running.

Verify the Helm release:

```bash
helm list -n monitoring
```

Expected status:

```text
deployed
```

---

# 12. Apply the ServiceMonitor

Apply the application ServiceMonitor:

```bash
kubectl apply \
  -f monitoring/cloudops-servicemonitor.yaml
```

Verify it:

```bash
kubectl get servicemonitor \
  cloudops-api-servicemonitor \
  -n monitoring
```

Display its configuration:

```bash
kubectl get servicemonitor \
  cloudops-api-servicemonitor \
  -n monitoring \
  -o custom-columns='NAME:.metadata.name,PATH:.spec.endpoints[*].path,PORT:.spec.endpoints[*].port'
```

Expected values:

```text
PATH: /metrics
PORT: http
```

---

# 13. Apply the Prometheus Alert Rules

Apply the PrometheusRule:

```bash
kubectl apply \
  -f monitoring/cloudops-prometheusrule.yaml
```

Verify the resource:

```bash
kubectl get prometheusrule \
  cloudops-api-alerts \
  -n monitoring
```

Display the alert names:

```bash
kubectl get prometheusrule \
  cloudops-api-alerts \
  -n monitoring \
  -o custom-columns='NAME:.metadata.name,GROUP:.spec.groups[*].name,ALERTS:.spec.groups[*].rules[*].alert'
```

Expected alerts:

```text
CloudOpsAPITargetDown
CloudOpsAPIErrorActivity
```

---

# 14. Access Prometheus

Open a dedicated WSL terminal:

```bash
kubectl port-forward \
  -n monitoring \
  service/prometheus-stack-kube-prom-prometheus \
  9090:9090
```

Keep this terminal running.

Open Prometheus in a Windows browser:

```text
http://localhost:9090
```

Prometheus targets:

```text
http://localhost:9090/targets
```

Prometheus rules:

```text
http://localhost:9090/rules
```

Prometheus alerts:

```text
http://localhost:9090/alerts
```

The CloudOps ServiceMonitor should display:

```text
2 / 2 up
```

Test the custom metrics using Prometheus queries:

```promql
cloudops_request_total
```

```promql
cloudops_error_total
```

```promql
sum(rate(cloudops_request_total[1m]))
```

---

# 15. Access Grafana

Open another dedicated WSL terminal:

```bash
kubectl port-forward \
  -n monitoring \
  service/prometheus-stack-grafana \
  3000:80
```

Keep this terminal running.

Retrieve the Grafana administrator password:

```bash
kubectl get secret \
  prometheus-stack-grafana \
  -n monitoring \
  -o jsonpath='{.data.admin-password}' \
  | base64 -d

echo
```

Open Grafana:

```text
http://localhost:3000
```

Login credentials:

```text
Username: admin
Password: output from the Kubernetes Secret command
```

---

# 16. Import the Grafana Dashboard

The exported dashboard file is:

```text
monitoring/grafana-dashboard.json
```

In Grafana:

1. Open **Dashboards**.
2. Select **New**.
3. Select **Import**.
4. Click **Upload dashboard JSON file**.
5. Select `monitoring/grafana-dashboard.json`.
6. Select the Prometheus datasource.
7. Click **Import**.

The dashboard should contain:

* CloudOps API Target Status
* Available Replicas
* Desired Replicas
* CloudOps API Request Rate
* CloudOps API Error Rate
* Total Simulated Errors
* CloudOps API CPU Usage
* CloudOps API Memory Usage
* FastAPI Process Memory

---

# 17. Generate Monitoring Traffic

Ensure the application port-forward is running on port `8001`.

Generate normal application traffic:

```bash
for i in $(seq 1 180); do
  curl -s -o /dev/null http://localhost:8001/
  curl -s -o /dev/null http://localhost:8001/health
  sleep 0.2
done
```

Generate simulated application errors:

```bash
for i in $(seq 1 50); do
  curl -s -o /dev/null \
    http://localhost:8001/simulate-error
  sleep 0.5
done
```

Wait for the Prometheus scrape interval:

```bash
sleep 20
```

Refresh the Grafana dashboard.

The following panels should respond:

* Request Rate
* Error Rate
* Total Simulated Errors
* CPU Usage
* Process Memory

---

# 18. Run Jenkins

Create a Jenkins directory when it does not exist:

```bash
mkdir -p ~/jenkins
```

Place `jenkins.war` in:

```text
~/jenkins/jenkins.war
```

Start Jenkins:

```bash
java -jar ~/jenkins/jenkins.war
```

Keep this terminal running.

Open Jenkins:

```text
http://localhost:8080
```

For the first Jenkins startup, retrieve the initial administrator password:

```bash
cat ~/.jenkins/secrets/initialAdminPassword
```

Complete the initial setup and install the suggested plugins.

---

# 19. Create the Jenkins Pipeline Job

In Jenkins:

1. Select **New Item**.
2. Enter a job name, for example:

```text
cloudops-ci-cd
```

3. Select **Pipeline**.
4. Select **OK**.
5. Open the **Pipeline** configuration section.
6. Set **Definition** to:

```text
Pipeline script from SCM
```

7. Set **SCM** to:

```text
Git
```

8. Enter the repository URL:

```text
https://github.com/nraditya/on-prem-cloud-native-platform.git
```

9. Set the branch:

```text
*/main
```

10. Set the script path:

```text
Jenkinsfile
```

11. Save the job.
12. Select **Build Now**.

The pipeline stages are:

1. Checkout
2. Verify Tools
3. Build Docker Image
4. Test Application
5. Import Image to k3d
6. Deploy to Kubernetes
7. Health Check

A successful pipeline ends with:

```text
Finished: SUCCESS
```

---

# 20. Verify the Jenkins Deployment

Check the latest deployed image:

```bash
kubectl get deployment cloudops-api \
  -n cloudops \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The Jenkins image format is:

```text
cloudops-status-api:jenkins-<BUILD_NUMBER>
```

Verify the rollout:

```bash
kubectl rollout status \
  deployment/cloudops-api \
  -n cloudops
```

Verify the Pods:

```bash
kubectl get pods -n cloudops
```

Test the health endpoint:

```bash
curl -i http://localhost:8001/health
```

---

# 21. Run Bash Automation

Make the scripts executable:

```bash
chmod +x scripts/*.sh
```

Run the available automation:

```bash
./scripts/start-cluster.sh
./scripts/health-check.sh
./scripts/check-monitoring.sh
```

Optional access scripts:

```bash
./scripts/open-prometheus.sh
./scripts/open-grafana.sh
```

Generate traffic:

```bash
./scripts/generate-traffic.sh
```

---

# 22. Run Ansible Validation

Run the Ansible playbook from the repository root:

```bash
ansible-playbook \
  -i ansible/inventory.ini \
  ansible/setup-local.yml
```

The playbook validates:

* Docker
* kubectl
* k3d
* Helm
* Terraform
* Kubernetes nodes
* Application Pods
* Monitoring Pods

---

# 23. Final Platform Verification

Run:

```bash
echo "===== CLUSTER ====="
kubectl get nodes

echo
echo "===== CLOUDOPS APPLICATION ====="
kubectl get deployment,pods,service -n cloudops

echo
echo "===== MONITORING COMPONENTS ====="
kubectl get pods -n monitoring

echo
echo "===== SERVICEMONITOR ====="
kubectl get servicemonitor \
  cloudops-api-servicemonitor \
  -n monitoring

echo
echo "===== PROMETHEUS RULE ====="
kubectl get prometheusrule \
  cloudops-api-alerts \
  -n monitoring

echo
echo "===== CURRENT APPLICATION IMAGE ====="
kubectl get deployment cloudops-api \
  -n cloudops \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The final expected condition is:

* Both Kubernetes nodes are `Ready`.
* The application Deployment is `2/2`.
* Both application Pods are `Running`.
* Monitoring Pods are `Running`.
* ServiceMonitor is available.
* PrometheusRule is available.
* Prometheus reports two CloudOps targets as `UP`.
* Grafana displays the CloudOps dashboard.
* Jenkins pipeline completes successfully.

---

# 24. Terminal Allocation

During normal operation, use separate terminals for long-running processes.

| Terminal   | Process                                   |
| ---------- | ----------------------------------------- |
| Terminal 1 | Jenkins on port `8080`                    |
| Terminal 2 | Application port-forward on port `8001`   |
| Terminal 3 | Prometheus port-forward on port `9090`    |
| Terminal 4 | Grafana port-forward on port `3000`       |
| Terminal 5 | Commands, testing, and traffic generation |

Do not close a terminal that is running Jenkins or a required port-forward.

---

# 25. Stop the Local Environment

Stop a port-forward by pressing:

```text
Ctrl+C
```

Stop Jenkins by pressing `Ctrl+C` in the Jenkins terminal.

Stop the k3d cluster without deleting it:

```bash
k3d cluster stop cloudops-cluster
```

Start it again:

```bash
k3d cluster start cloudops-cluster
```

Delete the cluster only when a complete rebuild is required:

```bash
k3d cluster delete cloudops-cluster
```

Deleting the cluster also removes Kubernetes workloads stored inside that cluster.

---

# Troubleshooting

## Docker Is Not Available

Check Docker Desktop on Windows.

Then run:

```bash
docker info
```

Do not recreate the Kubernetes cluster until Docker connectivity is restored.

## Wrong Kubernetes Context

Check:

```bash
kubectl config current-context
```

Switch to the project cluster:

```bash
kubectl config use-context k3d-cloudops-cluster
```

## Application Pod Uses `ImagePullBackOff`

Verify that the local image exists:

```bash
docker image ls cloudops-status-api
```

Import it again:

```bash
k3d image import \
  cloudops-status-api:local \
  --cluster cloudops-cluster
```

## Application Port Is Unavailable

Check whether port `8001` is already in use:

```bash
ss -ltnp | grep ':8001'
```

Stop the old port-forward or use another local port.

## Prometheus Does Not Discover the Application

Verify the ServiceMonitor:

```bash
kubectl describe servicemonitor \
  cloudops-api-servicemonitor \
  -n monitoring
```

Verify:

* Selector: `app=cloudops-api`
* Path: `/metrics`
* Port: `http`
* Namespace: `cloudops`

## Grafana Dashboard Has No Data

Verify that:

* Prometheus is available.
* The Prometheus datasource is selected.
* The CloudOps targets are `UP`.
* Application traffic has been generated.
* The dashboard time range includes the recent traffic.

## Jenkins Cannot Use Docker or Kubernetes

From the same WSL user that runs Jenkins, verify:

```bash
docker info
kubectl get nodes
k3d cluster list
```

Jenkins must be started from an environment that can access Docker, kubectl, and k3d.

