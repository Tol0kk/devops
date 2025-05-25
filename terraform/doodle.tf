# Public key push to the instances
resource "openstack_compute_keypair_v2" "test_keypair" {
  provider   = openstack.ovh             # Nom du fournisseur déclaré dans provider.tf
  name       = "test_keypair"            # Nom de la clé SSH à utiliser pour la création
  public_key = file(var.public_key_path) # Chemin vers votre clé SSH précédemment générée
  region          = var.region
}

# Private network for the project
resource "openstack_networking_network_v2" "doodle_network" {
  name           = "doodle_network"
  admin_state_up = true
  region          = var.region
}

# Private subnet for instance to instance communication
resource "openstack_networking_subnet_v2" "doodle_subnet" {
  name            = "doodle_subnet"
  network_id      = openstack_networking_network_v2.doodle_network.id
  ip_version      = 4
  region          = var.region
  no_gateway      = true # Pas de gateway par defaut
  enable_dhcp     = true # Activation du DHCP
  cidr            = "192.168.168.0/24"
  allocation_pool {
    start = "192.168.168.100"
    end   = "192.168.168.200"
  }
}

# Liste d'adresses IP privées possibles pour les frontaux
variable "worker_private_ip" {
  type          = list(any)
  default       = ["192.168.168.103", "192.168.168.104"]
}

# Based images for all the instances
data "openstack_images_image_v2" "os_image" {
  region        = var.region
  name          = "Ubuntu 24.10"   # Nom de l'image
  most_recent   = true          # Limite la recherche à la plus récente
  provider      = openstack.ovh # Nom du fournisseur
}

# Instances ressources
resource "openstack_compute_instance_v2" "master_instance" {
  provider    = openstack.ovh    
  region      = var.region
  name        = "master_instance"         
  image_name  = "Ubuntu 24.10"   
  # Discovery 2GB | 1vCPU (2GHz)
  flavor_name = "d2-2"
  key_pair    = openstack_compute_keypair_v2.test_keypair.name
  image_id    = data.openstack_images_image_v2.os_image.id
  network {
    name      = "Ext-Net" 
  }
  network {
    uuid      = openstack_networking_network_v2.doodle_network.id
    fixed_ip_v4 = "192.168.168.102"
  }
  block_device {
    uuid                  = data.openstack_images_image_v2.os_image.id # Identifiant de l'image de l'instance
    volume_size           = 3                                           # Taille
    source_type           = "image"                                     # Type de source
    destination_type      = "local"                                     # Destination
    boot_index            = 0                                           # Ordre de boot
    delete_on_termination = true                                        # Le périphérique sera supprimé quand l'instance sera supprimée
  }
  depends_on = [openstack_networking_subnet_v2.doodle_subnet]
}

resource "openstack_compute_instance_v2" "worker_instance" {
  count       = length(var.worker_private_ip)
  region = var.region
  provider    = openstack.ovh    
  name        = "worker_instance"         
  image_name  = "Ubuntu 24.10"   
  # Discovery 2GB | 1vCPU (2GHz)
  flavor_name = "d2-2"
  key_pair    = openstack_compute_keypair_v2.test_keypair.name
  image_id    = data.openstack_images_image_v2.os_image.id
  network {
    name      = "Ext-Net" 
  }
  network {
    uuid      = openstack_networking_network_v2.doodle_network.id
    fixed_ip_v4 = element(var.worker_private_ip, count.index)
  }
  block_device {
    uuid                  = data.openstack_images_image_v2.os_image.id # Identifiant de l'image de l'instance
    source_type           = "image"                                     # Type de source
    destination_type      = "local"                                     # Destination
    volume_size           = 3                                           # Taille
    boot_index            = 0                                           # Ordre de boot
    delete_on_termination = true                                        # Le périphérique sera supprimé quand l'instance sera supprimée
  }
  depends_on = [openstack_networking_subnet_v2.doodle_subnet]
}

# DNS Configs
resource "ovh_domain_zone_record" "master_node" {
  zone      = "doordle.ovh"
  subdomain = "master.nodes"
  fieldtype = "A"
  ttl       = 3600
  target    = openstack_compute_instance_v2.master_instance.network[0].fixed_ip_v4
}

resource "ovh_domain_zone_record" "worker_node" {
  count       = length(var.worker_private_ip)
  zone      = "doordle.ovh"
  subdomain = "worker${count.index}.nodes"
  fieldtype = "A"
  ttl       = 3600
  target    = openstack_compute_instance_v2.worker_instance[count.index].network[0].fixed_ip_v4
}
