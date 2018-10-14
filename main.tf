module "foo" {
  source = "modules/vhost"
  
  server_name = "foo.com"
}

module "bar" {
  source = "modules/vhost"
  
  server_name = "bar.com"
}