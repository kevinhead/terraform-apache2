resource "tls_private_key" "vhost" {
  algorithm = "ECDSA"

  provisioner "local-exec" {
    command = "echo '${tls_private_key.vhost.private_key_pem}' > '${var.private_key_file_path}/{}.key'"
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
    common_name  = "${var.server_name}"
  }

  provisioner "local-exec" {
    command = "echo '${tls_self_signed_cert.vhost.cert_pem}' > '${var.self_signed_cert_file_path}'"
  }
}

data "template_file" "vhost_config" {
  template = "${file("${path.module}/templates/vhost.conf")}"

  vars {
    server_name = "${var.server_name}"
  }
}

data "template_file" "vhost_public_html" {
  template = "${file("${path.module}/templates/public_html/index.html")}"

  vars {
    server_name = "${var.server_name}"
  }
}
