output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = var.namespace
}

output "root_application_name" {
  description = "Name of the root application"
  value       = kubernetes_manifest.root_application.manifest.metadata.name
}

