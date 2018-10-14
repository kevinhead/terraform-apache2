locals {
  private_key      = "/etc/ssl/private/${var.server_name}.key"
  self_signed_cert = "/etc/ssl/certs/${var.server_name}.pem"
  document_root    = "/var/www/${var.server_name}/public_html"
  sites_available  = "/etc/apache2/sites-available/${var.server_name}.conf"
  error_log        = "/var/log/apache2/${var.server_name}.error.log"
  custom_log       = "/var/log/apache2/${var.server_name}.access.log combined"
}

resource "tls_private_key" "vhost" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" {
    command = "echo '${tls_private_key.vhost.private_key_pem}' > '${local.private_key}'"
  }
}

resource "tls_self_signed_cert" "vhost" {
  key_algorithm   = "${tls_private_key.vhost.algorithm}"
  private_key_pem = "${tls_private_key.vhost.private_key_pem}"

  # Certificate expires after 12 hours.
  validity_period_hours = 12

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature"
  ]

  subject {
    common_name = "${var.server_name}"
  }

  # Cert
  provisioner "local-exec" {
    command = "echo '${tls_self_signed_cert.vhost.cert_pem}' > '${local.self_signed_cert}'"
  }

  # vhost conf
  provisioner "local-exec" {
    command = "echo '${data.template_file.vhost_config.rendered}' > '${local.sites_available}'"
  }

  # public_html index
  provisioner "local-exec" {
    command = "mkdir -p '${local.document_root}' && echo '${data.template_file.vhost_public_html.rendered}' > '${local.document_root}/index.html'"
  }

  # activate the new configuration
  provisioner "local-exec" {
    command = "echo '${var.server_name} 127.0.0.1' >> '/etc/hosts' && service apache2 reload"
  }
}

data "template_file" "vhost_config" {
  template = "${file("${path.module}/templates/vhost.conf")}"

  vars {
    server_name       = "${var.server_name}"
    document_root     = "${local.document_root}"
    ssl_cert_file     = "${local.self_signed_cert}"
    ssl_cert_key_file = "${local.private_key}"
    error_log         = "${local.error_log}"
    custom_log        = "${local.custom_log}"
  }
}

data "template_file" "vhost_public_html" {
  template = "${file("${path.module}/templates/public_html/index.html")}"

  vars {
    server_name = "${var.server_name}"
  }
}
