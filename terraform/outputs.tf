output "namespace" {
  value = kubernetes_namespace.cloudops.metadata[0].name
}

output "application_name" {
  value = kubernetes_deployment.cloudops_api.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.cloudops_api_service.metadata[0].name
}
