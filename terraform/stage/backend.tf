terraform {
  backend "gcs" {
    bucket = "bucket-t"
    prefix = "terraform/state"
  }
}
