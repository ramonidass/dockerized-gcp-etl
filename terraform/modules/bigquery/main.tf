
resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_name
  location   = var.region
  project    = var.project_id
}

resource "google_bigquery_table" "tables" {
  for_each   = { for table in var.tables : table.name => table }
  dataset_id = var.dataset_name
  table_id   = each.value.name
  project    = var.project_id
  schema     = file(each.value.schema)
  deletion_protection = false

  dynamic "time_partitioning" {
    for_each = each.key == "visits_information" ? [1] : []
    content {
      type  = "DAY"
      field = "visit_date"
    }
  }

  depends_on = [google_bigquery_dataset.dataset]
}
