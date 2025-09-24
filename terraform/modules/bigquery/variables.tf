
variable "project_id" {
 description = "The GCP project ID where the dataset will be created"
 type        = string
}

variable "region" {
 description = "The region for the BigQuery dataset"
 type        = string

}

variable "dataset_name" {
 description = "The name of the BigQuery dataset"
 type        = string
}

variable "tables" {
 description = "List of tables to create in the dataset"
 type = list(object({
   name   = string
   schema = string
 }))
}
