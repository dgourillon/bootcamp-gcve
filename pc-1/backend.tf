terraform {
  backend "gcs" {
    bucket = "tfstate-gcve-bootcamp"
    prefix = "pc1"
  }
}