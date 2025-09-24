terraform {
  backend "gcs" {
    bucket = "fms-state-bucket"
    prefix = "project-sat"
  }
}
