terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.14"
    }
  }
}

provider "harbor" {
  url      = var.url
  username = var.username
  password = var.password
}
