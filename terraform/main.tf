terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
     source  = "hashicorp/google"
     version = "~> 5.0"
   }
 }
}


provider "google" {
  project                     = var.project_ids[terraform.workspace]
  region                      = var.region
  impersonate_service_account = var.service_account_emails[terraform.workspace]
}