provider "google" {
  project = var.project_id
  region  = var.region
}

module "project_setup" {
  source                            = "../../modules/project-setup"
  project_id                        = var.project_id
  region                            = var.region
  artifact_registry_repository_name = "fms-app-repo"
}

module "bigquery" {
  source       = "../../modules/bigquery"
  project_id   = var.project_id
  region       = var.region
  dataset_name = "fms_prod"
  tables = [
    {
      name   = "visits_information"
      schema = "${path.module}/../../schemas/visits_information.json"
    },
    {
      name   = "dq_visits_information"
      schema = "${path.module}/../../schemas/dq_visits_information.json"
    }
  ]
}

module "cloud_run_service" {
  source                 = "../../modules/cloud-run"
  project_id             = var.project_id
  region                 = var.region
  cloud_run_service_name = "fms-data-pipeline-prod"
  image_url              = "${var.region}-docker.pkg.dev/${var.project_id}/${module.project_setup.repository_url}/fms-data-pipeline:latest"
  service_account_id     = "fms-data-pipeline-prod-sa"
  gcs_bucket_name        = "fms-data-pipeline-prod-events"
  eventarc_trigger_name  = "fms-data-pipeline-prod-trigger"
}
