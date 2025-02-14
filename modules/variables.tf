# variables.tf
variable "helm_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "namespace" {
  description = "Namespace for ArgoCD installation"
  type        = string
  default     = "argocd"
}

variable "repository_url" {
  description = "Git repository URL containing ArgoCD applications and projects"
  type        = string
  default     = "https://github.com/amunt0/argocd-apps.git"
}

variable "repository_branch" {
  description = "Git repository branch"
  type        = string
  default     = "main"
}

variable "additional_values" {
  description = "Additional values to merge with default values"
  type        = any
  default     = null
}

variable "cloud_provider" {
  description = "Cloud provider (aws, gcp, azure, alicloud, metal)"
  type        = string
  default     = "metal" # Default

  validation {
    condition     = contains(["aws", "gcp", "azure", "alicloud", "metal", ""], var.cloud_provider)
    error_message = "Valid values for cloud_provider are: aws, gcp, azure, alicloud, metal, or empty string"
  }
}

variable "additional_apps" {
  description = "List of additional applications to deploy beyond the minimum set"
  type        = list(string)
  default     = []
}

