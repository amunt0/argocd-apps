locals {
  default_values = {
    crds = {
      install = true
      keep    = true
    }
    configs = {
      params = {
        "server.insecure"     = true
        "server.disable.auth" = true
      }
    }
    controller = {
      resources = {
        requests = {
          cpu    = "250m"
          memory = "256Mi"
        }
        limits = {
          memory = "512Mi"
        }
      }
    }
    server = {
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          memory = "128Mi"
        }
      }
    }
    dex = {
      enabled = false
    }
    redis = {
      resources = {
        requests = {
          cpu    = "100m"
          memory = "64Mi"
        }
        limits = {
          memory = "128Mi"
        }
      }
    }
    repoServer = {
      resources = {
        requests = {
          cpu    = "10m"
          memory = "128Mi"
        }
        limits = {
          memory = "256Mi"
        }
      }
    }
    applicationSet = {
      enabled = true
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          memory = "128Mi"
        }
      }
    }
  }

  # Merge with any additional values provided
  values = var.additional_values != null ? merge(local.default_values, var.additional_values) : local.default_values
}
