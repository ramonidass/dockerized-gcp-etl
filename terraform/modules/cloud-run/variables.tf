variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for the resources."
  type        = string
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service."
  type        = string
}

variable "image_url" {
  description = "The full URL of the container image to deploy."
  type        = string
}

variable "service_account_id" {
  description = "The ID for the service account."
  type        = string
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket for the Eventarc trigger."
  type        = string
}

variable "eventarc_trigger_name" {
  description = "The name of the Eventarc trigger."
  type        = string
}
