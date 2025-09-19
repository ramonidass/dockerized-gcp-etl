resource "google_cloud_run_v2_service" "default" {
  name     = var.cloud_run_service_name
  location = var.region
  project  = var.project_ids[terraform.workspace]

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_ids[terraform.workspace]}/${var.artifact_registry_repository_name}/${var.cloud_run_service_name}:latest"
    }
  }

  depends_on = [google_project_service.api_enablement]
}

resource "google_service_account" "default" {
  account_id   = var.cloud_run_service_name
  display_name = "Cloud Run Service Account for FSM Data Pipeline"
  project      = var.project_ids[terraform.workspace]
}

resource "google_project_iam_member" "run_invoker" {
  project = var.project_ids[terraform.workspace]
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_storage_bucket" "default" {
  name     = "${var.gcs_bucket_name}-${terraform.workspace}"
  location = var.region
  project  = var.project_ids[terraform.workspace]
}

resource "google_eventarc_trigger" "default" {
  name     = "${var.cloud_run_service_name}-trigger-${terraform.workspace}"
  location = var.region
  project  = var.project_ids[terraform.workspace]

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }
  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.default.name
  }

  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.default.name
      region  = var.region
    }
  }
}
