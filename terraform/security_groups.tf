# Not allowed to create security group with OVH Openstack
# This would have been use full to allow ssh connection only to an ip. for example the static ipi of th it department of your entreprise. 

# resource "openstack_networking_secgroup_v2" "base" {
#   name = "${var.project}_sec_base"
#   description = "Base Security Group"
# }

# resource "openstack_networking_secgroup_rule_v2" "base_rule_ssh" {
#   direction         = "ssh ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 22
#   port_range_max    = 22
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = openstack_networking_secgroup_v2.base.id
# }

# resource "openstack_networking_secgroup_rule_v2" "base_rule_icmp" {
#   direction         = "icmp ingress"
#   ethertype         = "IPv4"
#   protocol       = "icmp"
#   port_range_min    = -1
#   port_range_max    = -1
#   remote_ip_prefix  = "${openstack_networking_subnet_v2.doodle_subnet.cidr}"
#   security_group_id = openstack_networking_secgroup_v2.base.id
# }

# resource "openstack_networking_secgroup_v2" "master" {
#   name = "${var.project}_sec_master"
#   description = "Master Security Group"
# }

# resource "openstack_networking_secgroup_rule_v2" "master_rule_websecure" {
#   direction         = "websecure ingress"
#   ethertype         = "IPv4"
#   protocol       = "tcp"
#   port_range_min    = 443
#   port_range_max    = 433
#   remote_ip_prefix  = "${openstack_networking_subnet_v2.doodle_subnet.cidr}"
#   security_group_id = openstack_networking_secgroup_v2.master.id
# }

# resource "openstack_networking_secgroup_rule_v2" "master_rule_web" {
#   direction         = "web ingress"
#   ethertype         = "IPv4"
#   protocol       = "tcp"
#   port_range_min    = 80
#   port_range_max    = 80
#   remote_ip_prefix  = "${openstack_networking_subnet_v2.doodle_subnet.cidr}"
#   security_group_id = openstack_networking_secgroup_v2.master.id
# }