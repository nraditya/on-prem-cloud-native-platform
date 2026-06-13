resource "kubernetes_namespace" "cloudops" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "cloudops_api" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.cloudops.metadata[0].name

    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name              = var.app_name
          image             = var.image_name
          image_pull_policy = "Never"

          port {
            container_port = 8000
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }

            initial_delay_seconds = 10
            period_seconds        = 20
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "cloudops_api_service" {
  metadata {
    name      = "cloudops-api-service"
    namespace = kubernetes_namespace.cloudops.metadata[0].name

    labels = {
      app = var.app_name
    }
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8000
    }

    type = "ClusterIP"
  }
}
