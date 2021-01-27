resource "google_container_cluster" "slack_test" {
  provider = google-beta
  name     = "slack-test"
  location = "europe-north1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  notification_config {
    pubsub {
      enabled = true
      topic   = google_pubsub_topic.gke_notify_topic.id
    }
  }

  depends_on = [
    google_pubsub_topic.gke_notify_topic
  ]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "slack_pool"
  location   = "europe-north1"
  cluster    = google_container_cluster.slack_test.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}