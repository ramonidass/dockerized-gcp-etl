terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  alias       = "prod"
  project     = var.project_ids["prod"]
  region      = var.region
  credentials = var.credentials_path != "" ? file(var.credentials_path) : null
}

provider "google" {
  alias       = "rnd"
  project     = var.project_ids["rnd"]
  region      = var.region
  credentials = var.credentials_path != "" ? file(var.credentials_path) : null
}
