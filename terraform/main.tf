resource "harbor_registry" "docker" {
  name          = "docker-hub"
  provider_name = "docker-hub"
  endpoint_url  = "https://hub.docker.com"
}

resource "harbor_project" "proxy" {
  name        = var.proxy_project_name
  registry_id = harbor_registry.docker.registry_id
}
