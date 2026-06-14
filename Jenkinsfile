pipeline {
    agent any

    environment {
        IMAGE_NAME = "cloudops-status-api"
        IMAGE_TAG = "jenkins-${BUILD_NUMBER}"
        FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
        K3D_CLUSTER = "cloudops-cluster"
        NAMESPACE = "cloudops"
        DEPLOYMENT_NAME = "cloudops-api"
        CONTAINER_NAME = "cloudops-api"
        SERVICE_NAME = "cloudops-api-service"
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
                    docker --version
                    kubectl version --client
                    k3d version
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${FULL_IMAGE} ./app
                    docker images | grep cloudops-status-api
                '''
            }
        }

        stage('Import Image to k3d') {
            steps {
                sh '''
                    k3d image import ${FULL_IMAGE} -c ${K3D_CLUSTER}
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=${FULL_IMAGE} -n ${NAMESPACE}
                    kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE} --timeout=120s
                    kubectl get pods -n ${NAMESPACE}
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    kubectl port-forward -n ${NAMESPACE} svc/${SERVICE_NAME} ${LOCAL_TEST_PORT}:80 > /tmp/cloudops-port-forward.log 2>&1 &
                    PF_PID=$!

                    sleep 5

                    curl -f http://localhost:${LOCAL_TEST_PORT}/health

                    kill $PF_PID || true
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
    }
}
