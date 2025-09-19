variable "project_ids" {
  description = "A map of Google Cloud project IDs for different environments."
  type        = map(string)
  default = {
    prod = "fms-prod-472514"
    rnd  = "fms-rnd"
  }
}

variable "region" {
  description = "The region for the resources."
  type        = string
  default     = "europe-west2"
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service."
  type        = string
  default     = "fsm-data-pipeline"
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket."
  type        = string
  default     = "fsm-data-pipeline-bucket"
}

variable "artifact_registry_repository_name" {
  description = "The name of the Artifact Registry repository."
  type        = string
  default     = "fsm-repository"
}

variable "service_account_emails" {
  description = "A map of service account emails to impersonate for each environment."
  type        = map(string)
  default = {
    prod = "github-action-deployer@fms-prod-472514.iam.gserviceaccount.com"
    rnd  = "github-action-deployer@fms-rnd.iam.gserviceaccount.com"
  }
}

variable "image_tag" {
  description = "The tag for the docker image"
  type        = string
  default     = "latest"
}

