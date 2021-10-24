output "service_account_name" {
  value = google_service_account.least-privilege-sa-for-gke.name
}

output "service_account_email" {
  value = google_service_account.least-privilege-sa-for-gke.email
}