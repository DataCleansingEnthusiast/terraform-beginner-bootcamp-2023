terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }
  
}

provider "terratowns" {
  endpoint = var.terratowns_endpoint
  user_uuid=var.teacherseat_user_uuid
  token=var.terratowns_access_token
}

module "terrahouse_aws" {
  source = "./modules/terrahouse_aws"
  user_uuid = var.teacherseat_user_uuid
  #bucket_name = var.bucket_name
  index_html_filepath = var.index_html_filepath
  error_html_filepath = var.error_html_filepath
  content_version = var.content_version
  assets_path         = var.assets_path
}

resource "terratowns_home" "home" {
  name        = "Climate change "
  description = <<DESCRIPTION
  roopish, a technologist/mom/global citizen is trying to figure out what she can do about climate change.
  There are things each of us can do to minimize our environmental impact. 
  DESCRIPTION
  domain_name = module.terrahouse_aws.cloudfront_url
  town            = "missingo"
  content_version = 1
}