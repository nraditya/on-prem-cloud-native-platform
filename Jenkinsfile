pipeline {
agent any

```
options {
    timestamps()
    disableConcurrentBuilds()
}

environment {
    IMAGE_NAME      = "cloudops-status-api"
    IMAGE_TAG       = "jenkins-${BUILD_NUMBER}"
    FULL_IMAGE      = "${IMAGE_NAME}:${IMAGE_TAG}"

    K3D_CLUSTER     = "cloudops-cluster"
    NAMESPACE       = "cloudops"
    DEPLOYMENT_NAME = "cloudops-api"
    CONTAINER_NAME  = "cloudops-api"
    SERVICE_NAME    = "cloudops-api-service"

    LOCAL_TEST_PORT = "8002"
}

stages {
    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Verify Tools') {
        steps {
            sh '''
                set -eu

                echo "=== Docker ==="
                docker --version

                echo ""
                echo "=== kubectl ==="
                kubectl version --client

                echo ""
                echo "=== k3d ==="
                k3d version

                echo ""
                echo "=== Kubernetes cluster ==="
                kubectl get nodes
            '''
        }
    }

    stage('Build Docker Image') {
        steps {
            sh '''
                set -eu

                echo "=== Building image: ${FULL_IMAGE} ==="

                docker build \
                  -t "${FULL_IMAGE}" \
                  ./app

                echo ""
                echo "=== Verifying runtime container user ==="

                docker run \
                  --rm \
                  "${FULL_IMAGE}" \
                  id

                echo ""
                echo "=== Image created successfully ==="

                docker images \
                  --filter "reference=${FULL_IMAGE}"
            '''
        }
    }

    stage('Test Application') {
        steps {
            sh '''
                set -eu

                echo "=== Running automated tests ==="

                docker run \
                  --rm \
                  --user 0:0 \
                  -v "${WORKSPACE}:/workspace" \
                  -w /workspace \
                  "${FULL_IMAGE}" \
                  sh -c '
                    python -m pip install \
                      --no-cache-dir \
                      -r app/requirements-dev.txt

                    python -m pytest \
                      -v \
                      -p no:cacheprovider
                  '

                echo ""
                echo "=== Automated tests passed ==="
            '''
        }
    }

    stage('Import Image to k3d') {
        steps {
            sh '''
                set -eu

                echo "=== Importing ${FULL_IMAGE} into k3d ==="

                k3d image import \
                  "${FULL_IMAGE}" \
                  -c "${K3D_CLUSTER}"
            '''
        }
    }

    stage('Deploy to Kubernetes') {
        steps {
            sh '''
                set -eu

                echo "=== Updating Kubernetes deployment ==="

                kubectl set image \
                  "deployment/${DEPLOYMENT_NAME}" \
                  "${CONTAINER_NAME}=${FULL_IMAGE}" \
                  -n "${NAMESPACE}"

                echo ""
                echo "=== Waiting for rollout ==="

                kubectl rollout status \
                  "deployment/${DEPLOYMENT_NAME}" \
                  -n "${NAMESPACE}" \
                  --timeout=120s

                echo ""
                echo "=== Application pods ==="

                kubectl get pods \
                  -n "${NAMESPACE}"

                echo ""
                echo "=== Deployed image ==="

                kubectl get deployment \
                  "${DEPLOYMENT_NAME}" \
                  -n "${NAMESPACE}" \
                  -o jsonpath='{.spec.template.spec.containers[0].image}'

                echo ""
            '''
        }
    }

    stage('Health Check') {
        steps {
            sh '''
                set -eu

                PF_PID=""

                cleanup() {
                    if [ -n "${PF_PID}" ]; then
                        echo "Stopping port-forward process ${PF_PID}..."
                        kill "${PF_PID}" 2>/dev/null || true
                        wait "${PF_PID}" 2>/dev/null || true
                    fi
                }

                trap cleanup EXIT INT TERM

                echo "=== Starting Kubernetes port-forward ==="

                kubectl port-forward \
                  -n "${NAMESPACE}" \
                  "svc/${SERVICE_NAME}" \
                  "${LOCAL_TEST_PORT}:80" \
                  > /tmp/cloudops-jenkins-port-forward.log 2>&1 &

                PF_PID=$!

                echo "Port-forward PID: ${PF_PID}"

                for attempt in 1 2 3 4 5 6 7 8 9 10; do
                    echo "Health check attempt ${attempt}/10..."

                    if curl -fsS \
                      "http://localhost:${LOCAL_TEST_PORT}/health"; then

                        echo ""
                        echo "Health check passed."
                        exit 0
                    fi

                    sleep 2
                done

                echo ""
                echo "Health check failed."

                cat /tmp/cloudops-jenkins-port-forward.log || true

                exit 1
            '''
        }
    }
}

post {
    success {
        echo 'CI/CD pipeline completed successfully.'
    }

    failure {
        echo 'CI/CD pipeline failed. Check the console output.'
    }

    always {
        sh '''
            docker image prune -f || true
        '''
    }
}
```

}

