module "example" {
  source = "github.com/kevinhead/terraform-apache-vhost"
  
  subject_common_name = "example.com"
  dns_names = ["example.com", "www.example.com"]

}
