terraform {
  backend "gcs" {
    bucket = "bucket-p"
    prefix = "terraform/state"
  }
}
