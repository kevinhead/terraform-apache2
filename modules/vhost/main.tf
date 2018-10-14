locals {
  private_key = "/etc/ssl/private/${var.server_name}.key"
  self_signed_cert = "/etc/ssl/certs/${var.server_name}.crt"
  document_root   = "/var/www/${var.server_name}/public_html/index.html"
  sites_available = "/etc/apache2/sites-available/${var.server_name}.conf"
  error_log       = "/var/log/apache2/${var.server_name}.error.log"
  custom_log      = "/var/log/apache2/${var.server_name}.access.log combined"
}

resource "tls_private_key" "vhost" {
  algorithm = "ECDSA"

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
    "digital_signature",
    "server_auth",
  ]

  subject {
    common_name = "${var.server_name}"
  }

  # Cert
  provisioner "local-exec" {
    command = "echo '${tls_self_signed_cert.vhost.cert_pem}' > '${local.self_signed_cert}'"
  }

  # vhost conf
  provisioner "file" {
    content     = "${data.template_file.vhost_config.rendered}"
    destination = "${local.sites_available}"
  }

  # public_html index
  provisioner "file" {
    content     = "${data.template_file.vhost_public_html.rendered}"
    destination = "${local.document_root}"
  }

  # activate the new configuration
  provisioner "local-exec" {
    command = "service apache2 reload"
  }
}

data "template_file" "vhost_config" {
  template = "${file("${path.module}/templates/vhost.conf")}"

  vars {
    server_name    = "${var.server_name}"
    document_root  = "${local.document_root}"
    error_log  = "${local.error_log}"
    custom_log = "${local.custom_log}"
  }
}

data "template_file" "vhost_public_html" {
  template = "${file("${path.module}/templates/public_html/index.html")}"

  vars {
    server_name = "${var.server_name}"
  }
}
