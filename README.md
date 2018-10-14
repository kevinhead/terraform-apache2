# Terraform Apache2

## Overview

Apache2 plan which creates any number of VirtualHosts.

## Notes

Created for Vagrant project <https://github.com/kevinhead/vagrant-up>

## Module (modules/vhost)

    - creates self-signed tls cert
    - generates virtualhost conf (https only)
    - generates index.html
    - adds hosts entry
    - reloads apache2 service

## Usage

```terraform
    module "foo_site" {
        source = "modules/vhost"
  
        server_name = "foo.com"
    }
```