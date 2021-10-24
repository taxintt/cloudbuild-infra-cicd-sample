terraform {
  backend "gcs" {
    bucket = "tfstate-gcs-bucket-for-cloudbuild-cicd-test"
    prefix = "terraform/tfstate"
  }
}

