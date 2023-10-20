## Terrahome AWS

```tf
module "home_climatechange" {
  source = "./modules/terrahouse_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path     = var.climatechange.public_path
  content_version = var.climatechange.content_version
}
```

The public directory expects the following:
- index.html
- error.html
- assets

ALl top level files in assets will be copied, but not any subdirectories.