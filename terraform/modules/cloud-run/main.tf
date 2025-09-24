resource "google_cloud_run_v2_service" "default" {
  name     = var.cloud_run_service_name
  location = var.region
  project  = var.project_id

  template {
    containers {
      image = var.image_url
    }
    service_account = google_service_account.default.email
  }
}

resource "google_service_account" "default" {
  account_id   = var.service_account_id
  display_name = "Cloud Run Service Account for ${var.cloud_run_service_name}"
  project      = var.project_id
}

resource "google_project_iam_member" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_storage_bucket" "default" {
  name     = var.gcs_bucket_name
  location = var.region
  project  = var.project_id
}

resource "google_eventarc_trigger" "default" {
  name     = var.eventarc_trigger_name
  location = var.region
  project  = var.project_id

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

  service_account = google_service_account.default.email
}
