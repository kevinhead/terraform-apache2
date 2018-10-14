variable "server_name" {
  description = "virtual host server name, ex: 'yourdomain.com'"
  type        = "string"
}

# Example of optional vars
variable "private_key_file_path" {
  description = "folder path where the auto generated private key will be placed. (no trailing '/')"
  default     = "/etc/ssl/private"
  type        = "string"
}

variable "self_signed_cert_file_path" {
  description = "folder path where the auto generated self-signed cert will be placed. (no trailing '/')"
  default     = "/etc/ssl/certs"
  type        = "string"
}

