# main.tf
resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  repository       = "oci://ghcr.io/argoproj/argo-helm"
  chart            = "argo-cd"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = true

  values = [
    yamlencode(local.values)
  ]
}

# Wait for ArgoCD to be ready
resource "time_sleep" "wait_for_argo" {
  depends_on = [helm_release.argo_cd]
  create_duration = "30s"
}

# Apply projects
resource "null_resource" "apply_projects" {
  depends_on = [time_sleep.wait_for_argo]

  triggers = {
    projects_hash = sha1(join("", [for f in fileset("${path.module}/projects", "*.yaml") : filesha1("${path.module}/projects/${f}")]))
  }

  provisioner "local-exec" {
    command = <<-EOF
      kubectl wait --for=condition=available --timeout=60s deployment/argo-cd-argocd-server -n ${var.namespace}
      for file in ${path.module}/projects/*.yaml; do
        envsubst < $file | kubectl apply -f -
      done
    EOF
    
    environment = {
      argo_cd_namespace = var.namespace
    }
  }
}

# Apply applications
resource "null_resource" "apply_applications" {
  depends_on = [null_resource.apply_projects]

  triggers = {
    root_apps_hash = sha1(join("", [
      for f in fileset("${path.module}/applications", "*.yaml") : filesha1("${path.module}/applications/${f}")
    ]))
    generic_apps_hash = sha1(join("", [
      for f in fileset("${path.module}/applications/generic", "*.yaml") : filesha1("${path.module}/applications/generic/${f}")
    ]))
  }

  provisioner "local-exec" {
    command = <<-EOF
      # Apply root applications
      for file in ${path.module}/applications/*.yaml; do
        envsubst < $file | kubectl apply -f -
      done
      
      # Apply generic applications
      for file in ${path.module}/applications/generic/*.yaml; do
        envsubst < $file | kubectl apply -f -
      done
    EOF

    environment = {
      argo_cd_namespace = var.namespace
    }
  }
}