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
  for_each = {
    for pair in setproduct(keys(var.project_ids), local.required_apis) :
    "${pair[0]}-${pair[1]}" => {
      project = var.project_ids[pair[0]]
      service = pair[1]
      alias   = pair[0]
    }
  }

  provider = google[each.value.alias]
  project  = each.value.project
  service  = each.value.service

  # prevents Terraform from trying to disable the API when the resource is destroyed.
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "docker_repo" {
  for_each = var.project_ids

  provider      = google[each.key]
  project       = each.value
  location      = var.region
  repository_id = var.artifact_registry_repository_name
  description   = "Docker repository for FSM application images"
  format        = "DOCKER"
}
