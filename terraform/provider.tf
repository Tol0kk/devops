# Définir les providers et fixer les versions
terraform {
  required_version = ">= 1.1.0" # Prend en compte les versions de terraform à partir de la 0.14.0
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.42.0"
    }
    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.2.0"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = ">= 2.0.1"
    # }
  }
}

# Configure le fournisseur OpenStack hébergé par OVHcloud
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/" 
  domain_name = "default"                        
  alias       = "ovh"                            
}

# Configure le fournisseur OVH
provider "ovh" {
  endpoint = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}
