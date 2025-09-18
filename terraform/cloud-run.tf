
resource "google_cloud_run_v2_service" "default" {
 for_each = var.project_ids
 provider = google[each.key]
 name     = var.cloud_run_service_name
 location = var.region
 project  = each.value

 template {
   containers {
     image = "${var.region}-docker.pkg.dev/${each.value}/${var.
artifact_registry_repository_name}/${var.cloud_run_service_name}:latest"
   }
   service_account = google_service_account.default[each.key].email
 }
}

resource "google_service_account" "default" {
  for_each     = var.project_ids
  provider     = google[each.key]
  account_id   = var.cloud_run_service_name
  display_name = "Cloud Run Service Account for FSM Data Pipeline"
  project      = each.value
}

resource "google_project_iam_member" "run_invoker" {
  for_each = var.project_ids
  provider = google[each.key]
  project  = each.value
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.default[each.key].email}"
}

resource "google_storage_bucket" "default" {
  for_each = var.project_ids
  provider = google[each.key]
  name     = "${var.gcs_bucket_name}-${each.key}"
  location = var.region
  project  = each.value
}

resource "google_eventarc_trigger" "default" {
  for_each = var.project_ids
  provider = google[each.key]
  name     = "${var.cloud_run_service_name}-trigger"
  location = var.region
  project  = each.value

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }
  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.default[each.key].name
  }

  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.default[each.key].name
      region  = var.region
    }
  }

  service_account = google_service_account.default[each.key].email
}
