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
            name           = "http"
            container_port = 8000
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }

            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          security_context {
            run_as_non_root            = true
            run_as_user                = 10001
            run_as_group               = 10001
            allow_privilege_escalation = false
            read_only_root_filesystem  = true

            capabilities {
              drop = ["ALL"]
            }
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }

            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }

            initial_delay_seconds = 10
            period_seconds        = 20
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }
      }
    }
  }

  lifecycle {
    # Terraform mengelola konfigurasi infrastruktur,
    # sedangkan Jenkins mengelola versi image aplikasi.
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].image
    ]
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
