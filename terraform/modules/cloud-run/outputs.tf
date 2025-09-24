output "service_url" {
  description = "The URL of the Cloud Run service."
  value       = google_cloud_run_v2_service.default.uri
}

output "gcs_bucket_name" {
  description = "The name of the GCS bucket."
  value       = google_storage_bucket.default.name
}

output "service_account_email" {
  description = "The email of the service account created."
  value       = google_service_account.default.email
}
