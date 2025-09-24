variable "project_id" {
  description = "The GCP project ID where the resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region for the resources."
  type        = string
}

variable "artifact_registry_repository_name" {
  description = "The name for the Artifact Registry repository."
  type        = string
}

variable "required_apis" {
  description = "A list of GCP APIs to enable on the project."
  type        = list(string)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudrun.googleapis.com",
    "eventarc.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}
