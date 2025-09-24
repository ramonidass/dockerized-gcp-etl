
provider "google" {
  project = var.project_id
}
provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = var.service_account_emails
}

