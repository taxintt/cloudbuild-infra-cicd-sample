plugin "google" {
  enabled = true
  version = "0.13.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
  deep_check = true
}

config {
  module = true
  force = false
}