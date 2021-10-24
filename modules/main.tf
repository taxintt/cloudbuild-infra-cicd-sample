terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.89.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.89.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.6.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = data.google_client_config.current.access_token

  # client_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  # client_key = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}

module "iam" {
  source = "./iam"

  project_id = var.project_id
}

module "network" {
  source = "./network"

  project_id = var.project_id
  network    = var.network
}

data "google_client_config" "current" {}


# generating a kubeconfig entry:
# gcloud container clusters get-credentials tf-gke --project <project_id>
resource "google_container_cluster" "primary" {
  name     = "tf-gke"
  project  = var.project_id
  location = var.zone

  remove_default_node_pool = true
  min_master_version       = var.node_version
  initial_node_count       = 1

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions
  # https://github.com/hashicorp/terraform-provider-google/issues/3966
  provider = "google-beta"

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#monitoring_service
  # https://cloud.google.com/kubernetes-engine/docs/how-to/small-cluster-tuning?hl=ja#kubernetes-engine-monitoring
  monitoring_service = "none"

  addons_config {
    istio_config {
      disabled = true
      auth     = "AUTH_NONE"
    }
    http_load_balancing {
      disabled = true
    }
    # To use the Istio CNI feature, the network-policy GKE feature must be enabled in the cluster.
    # https://istio.io/latest/docs/setup/platform-setup/gke/
    network_policy_config {
      disabled = false
    }
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform#vpc-native-clusters
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  depends_on = [
    module.iam.service_account_name,
  ]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name     = "node-pool-for-tf-gke"
  cluster  = google_container_cluster.primary.name
  project  = google_container_cluster.primary.project
  location = google_container_cluster.primary.location

  node_count = 3

  # https://blog.yukirii.dev/create-gke-with-least-privilege-sa-using-terraform/
  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = module.iam.service_account_name

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    tags = ["istio"]
  }

  depends_on = [
    module.iam.service_account_name,
  ]
}
