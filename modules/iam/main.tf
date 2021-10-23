# https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa
resource "google_service_account" "least-privilege-sa-for-gke" {
  project    = var.project_id
  account_id = "least-privilege-sa-for-gke"
}

resource "google_project_iam_member" "gke_node_pool_roles" {
  project = var.project_id
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.objectViewer"
  ])
  role   = each.value
  member = "serviceAccount:${google_service_account.least-privilege-sa-for-gke.email}"
}

# do not use binding resource
# ロールに対して指定したメンバーを割り当てるためのリソースなので、削除すると他のメンバーのRoleも外れる
# resource "google_service_account_iam_binding" "monitoring-viewer" {
#   service_account_id = google_service_account.least-privilege-sa-for-gke.name
#   role               = "roles/monitoring.viewer"

#   members = [
#     "serviceAccount:${var.sa_name}@${var.project_id}.iam.gserviceaccount.com",
#   ]
# }
