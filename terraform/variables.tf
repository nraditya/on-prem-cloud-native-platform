variable "namespace" {
  description = "Kubernetes namespace for the CloudOps application"
  type        = string
  default     = "cloudops"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "cloudops-api"
}

variable "image_name" {
  description = "Docker image name"
  type        = string
  default     = "cloudops-status-api:local"
}

variable "replica_count" {
  description = "Number of application replicas"
  type        = number
  default     = 2
}
