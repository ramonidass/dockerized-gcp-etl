variable "project_ids" {
  description = "A map of Google Cloud project IDs for different environments."
  type        = map(string)
  default = {
    prod = "fms-prod"
    rnd  = "fms-rnd"
  }
}

variable "region" {
  description = "The region for the resources."
  type        = string
  default     = "europe-west2"
}

variable "credentials_path" {
  description = "The path to the Google Cloud credentials file."
  type        = string
  default     = ""
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

variable "service_account_email" {
  description = "The email of the service account for the Cloud Run service."
  type        = string
}

variable "artifact_registry_repository_name" {
 description = "The name of the Artifact Registry repository."
 type        = string
 default     = "fsm-repository"
}
