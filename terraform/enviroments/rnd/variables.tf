
variable "project_id" {
 description = "The GCP project ID for the rnd environment"
 type        = string
}

variable "region" {
 description = "The region for the BigQuery dataset"
 type        = string
 default     = "europe-west2"
}
