variable "url" {
  description = "The url of harbor"
  type        = string
}

variable "username" {
  description = "The username to be used to access harbor"
  type        = string
}

variable "password" {
  description = "The password to be used to access harbor"
  type        = string
}

variable "proxy_project_name" {
  description = "The name of the project that will be created in harbor."
  type        = string
  default     = "proxy_cache"
}
