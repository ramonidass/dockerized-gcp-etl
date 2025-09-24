resource "google_project_service" "api_enablement" {
  for_each = toset(var.required_apis)
  project  = var.project_id
  service  = each.value

  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_registry_repository_name
  description   = "Docker repository for application images"
  format        = "DOCKER"

  depends_on = [google_project_service.api_enablement]
}
