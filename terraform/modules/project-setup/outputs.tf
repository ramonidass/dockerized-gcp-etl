output "repository_url" {
  description = "The URL of the Artifact Registry repository."
  value       = google_artifact_registry_repository.docker_repo.name
}
