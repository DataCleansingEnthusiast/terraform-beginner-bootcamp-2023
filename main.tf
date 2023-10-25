terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
    
  }
  
  cloud {
    organization = "roopish-bootcamp"
    workspaces {
      name = "terra-house-1"
    }
}
}

provider "terratowns" {
  endpoint = var.terratowns_endpoint
  user_uuid=var.teacherseat_user_uuid
  token=var.terratowns_access_token
}

# module "home_climatechange_hosting" {
#   source = "./modules/terrahome_aws"
#   user_uuid = var.teacherseat_user_uuid
#   public_path     = var.climatechange.public_path
#   content_version = var.climatechange.content_version
# }

# resource "terratowns_home" "climatechange" {
#   name        = "Climate change "
#   description = <<DESCRIPTION
#   roopish, a technologist/mom/global citizen is trying to figure out what she can do about climate change.
#   There are things each of us can do to minimize our environmental impact. 
#   DESCRIPTION
#   domain_name = module.home_climatechange_hosting.domain_name
#   town            = "missingo"
#   content_version = var.climatechange.content_version
# }
module "home_music_hosting" {
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path     = var.music.public_path
  content_version = var.music.content_version
}

resource "terratowns_home" "music" {
  name        = "Music"
  description = <<DESCRIPTION
  Indian fusion music is a captivating blend of traditional Indian musical elements, such as classical instruments and melodies, with Western and global music genres, resulting in a harmonious fusion of diverse musical traditions. 
  This genre often celebrates the cross-cultural exchange of musical ideas, creating a rich tapestry of sound that resonates with audiences worldwide. "Shakti" is one such fusion band that started in 1973.
  DESCRIPTION
  domain_name = module.home_music_hosting.domain_name
  town            = "melomaniac-mansion"
  content_version = var.music.content_version
}

#2
module "home_travel_hosting" {
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path     = var.travel.public_path
  content_version = var.travel.content_version
}

#2
resource "terratowns_home" "travel" {
  name        = "Travelling "
  description = <<DESCRIPTION
  I have always loved to travel. It allows you to step away from your daily routine, providing a break from the monotony of everyday life.
  Traveling exposes you to different cultures, languages, and ways of life.
  DESCRIPTION
  domain_name = module.home_travel_hosting.domain_name
  town            = "the-nomad-pad"
  content_version = var.travel.content_version
}

