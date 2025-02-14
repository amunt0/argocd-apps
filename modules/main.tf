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
    apps_hash = sha1(jsonencode(local.apps_to_deploy))
  }
  provisioner "local-exec" {
    command = <<-EOF
      # Apply minimum and cloud-specific applications
      for app in ${join(" ", local.apps_to_deploy)}; do
        if [ -f "${path.module}/applications/generic/$${app}.yaml" ]; then
          envsubst < "${path.module}/applications/generic/$${app}.yaml" | kubectl apply -f -
        elif [ -f "${path.module}/applications/${var.cloud_provider}/$${app}.yaml" ]; then
          envsubst < "${path.module}/applications/${var.cloud_provider}/$${app}.yaml" | kubectl apply -f -
        fi
      done
    EOF
    environment = {
      argo_cd_namespace = var.namespace
    }
  }
}