resource "google_storage_bucket" "source_code" {
  name                        = var.gcf_source_bucket
  project                     = var.gcp_project_id
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}

#
# ZIP node_js source code to the bucket

data "archive_file" "code" {
  type        = "zip"
  output_path = "./${var.notify_zip}"

  source {
    content  = "${file("./index.js")}"
    filename = "index.js"
  }

  source {
    content  = "${file("./package.json")}"
    filename = "package.json"
  }
}

#
# Store zip to GCS Bucket for Cloud Functions

resource "google_storage_bucket_object" "source_code" {
  name       = var.notify_zip
  bucket     = google_storage_bucket.source_code.name
  source     = "./${var.notify_zip}"
  depends_on = [data.archive_file.code]
}

resource "google_cloudfunctions_function" "gke_notify_function" {
  provider    = google-beta
  name        = "gke-notify-function"
  description = "GCS Bucket for gke slack notifications"
  region      = var.gcp_function_region
  runtime     = "nodejs10"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.source_code.name
  source_archive_object = google_storage_bucket_object.source_code.name
  timeout               = 60
  entry_point           = "slackNotifier"

  environment_variables = {
    SLACK_WEBHOOK_URL = "var.slack_webhook"
  }

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.gke_notify_topic.name
  }
}

#
# IAM permissions for Cloud Functions to access buckets
#
# Cloud Functions needs to be able to read the source bucket and object, and store the object to the 
# destination bucket.
#

resource "google_storage_bucket_iam_member" "function_source" {

  bucket = google_storage_bucket.source_code.name
  role   = "roles/storage.objectViewer"
  member = google_cloudfunctions_function.gke_notify_function.service_account_email
}

resource "google_storage_bucket_iam_member" "function_destination" {
  bucket = google_storage_bucket.source_code.name
  role   = "roles/storage.objectCreator"
  member = google_cloudfunctions_function.gke_notify_function.service_account_email
}