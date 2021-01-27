#
# GCS Bucket for function's source code

variable gcf_source_bucket {
  type        = string
  description = "GCS Bucket for function's source code"
  default     = "gke-slack-notifier-bucket"
}

#
# Zip name for Cloud Functions source code

variable notify_zip {
  type        = string
  description = "Filename for zip to contain the source code"
  default     = "gke-notify.zip"
}

# All GCP regions do not support Cloud Functions
# https://cloud.google.com/functions/docs/locations
variable gcp_function_region {
  type        = string
  description = "Region for Cloud Functions"
  default     = "europe-west3"
}

#
# GCP Project and Region for resources

variable gcp_project_id {
  type        = string
  description = "GCP Project ID"
  default     = "victor69420"
}

variable gcp_region {
  type        = string
  description = "GCP Region"
  default     = "europe-north1"
}

variable slack_webhook {
  type        = string
  description = "Webhook generaged by Slack application to receive notifications"
  default     = "https://hooks.slack.com/services/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"
}