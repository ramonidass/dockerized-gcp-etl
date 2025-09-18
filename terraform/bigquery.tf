locals {
  datasets = {
    fsm_prod = {
      name   = "fsm_prod"
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
    fsm_rnd = {
      name   = "fsm_rnd"
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

  # Each object in the list represents a table with its dataset, name, and schema.
  tables = flatten([
    for project_key, project_id in var.project_ids : [
      for dataset_key, dataset_value in local.datasets : [
        for table in dataset_value.tables : {
          project = project_key
          dataset = dataset_value.name
          name    = table.name
          schema  = table.schema
        }
      ]
    ]
  ])
}

resource "google_bigquery_dataset" "datasets" {
  for_each   = { for k, v in var.project_ids : k => v }
  provider   = google[each.key]
  dataset_id = "fsm_${each.key}"
  location   = var.region
  project    = each.value
}

resource "google_bigquery_table" "tables" {
  for_each            = { for table in local.tables : "${table.project}.${table.dataset}.${table.name}" => table }
  provider            = google[each.value.project]
  dataset_id          = each.value.dataset
  table_id            = each.value.name
  project             = var.project_ids[each.value.project]
  schema              = each.value.schema
  deletion_protection = false
}
