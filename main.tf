module "foo_site" {
  source = "modules/vhost"
  
  server_name = "foo.com"
}

module "bar_site" {
  source = "modules/vhost"
  
  server_name = "bar.com"
}

# Add any additional sites...
# module "sub_bar_site" {
#   source = "modules/vhost"
  
#   server_name = "sub.bar.com"
# }