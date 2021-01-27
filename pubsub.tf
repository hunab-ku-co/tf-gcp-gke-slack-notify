resource "google_pubsub_topic" "gke_notify_topic" {
  name    = "gkeNotifyTopic"
  project = var.gcp_project_id
  labels = {
    system = "gke cluster"
  }
}

resource "google_pubsub_subscription" "gke_notify_subscription" {
  name  = "gkeNotifySub"
  topic = google_pubsub_topic.gke_notify_topic.name

  labels = {
    system = "gke cluster"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering = false
}