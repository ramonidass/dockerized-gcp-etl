locals {
  required_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudrun.googleapis.com",
    "eventarc.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

resource "google_project_service" "api_enablement" {
  for_each = toset(local.required_apis)
  project  = var.project_ids[terraform.workspace]
  service  = each.value

  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_ids[terraform.workspace]
  location      = var.region
  repository_id = var.artifact_registry_repository_name
  description   = "Docker repository for FSM application images"
  format        = "DOCKER"
}
