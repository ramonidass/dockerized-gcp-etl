locals {
  dataset_name = "fms_${terraform.workspace}"
  datasets = {
    fms_prod = {
      name   = "fms_prod"
      tables = [
        {
          name   = "visits_information"
          schema = file("${path.module}/schemas/visits_information.json")
        },
        {
          name   = "dq_visits_information"
          schema = file("${path.module}/schemas/dq_visits_information.json")
        }
      ]
    },
    fms_rnd = {
      name   = "fms_rnd"
      tables = [
        {
          name   = "visits_information"
          schema = file("${path.module}/schemas/visits_information.json")
        },
        {
          name   = "dq_visits_information"
          schema = file("${path.module}/schemas/dq_visits_information.json")
        }
      ]
    }
  }

  tables = flatten([
    for table in local.datasets[local.dataset_name].tables : {
      dataset = local.dataset_name
      name    = table.name
      schema  = table.schema
    }
  ])
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = local.dataset_name
  location   = var.region
  project    = var.project_ids[terraform.workspace]
}

resource "google_bigquery_table" "tables" {
  for_each   = { for table in local.tables : table.name => table }
  dataset_id = each.value.dataset
  table_id   = each.value.name
  project    = var.project_ids[terraform.workspace]
  schema     = each.value.schema
  deletion_protection = false

  depends_on = [google_bigquery_dataset.dataset]
}
