# output "dns_record" {
#   value = "www.example.com -> ${ovh_domain_zone_record.example.target}"
# }

output "instances_info" {
  description = "Print Information about the created instance"
  value = <<EOT
  ======================
          OUTPUT        
  ======================

  Used Public key: ${openstack_compute_keypair_v2.test_keypair.public_key}

  Master: 
    - Name: ${openstack_compute_instance_v2.master_instance.name}
    - Public IPv4: ${ovh_domain_zone_record.master_node.subdomain}.${ovh_domain_zone_record.master_node.zone} (${openstack_compute_instance_v2.master_instance.network[0].fixed_ip_v4})
    - Private IPv4: ${openstack_compute_instance_v2.master_instance.network[1].fixed_ip_v4}
  Slaves:
${join("\n", [
    for index, i in openstack_compute_instance_v2.worker_instance : 
  "    - Name: ${i.name}\n      Public IPv4: ${ovh_domain_zone_record.worker_node[index].subdomain}.${ovh_domain_zone_record.worker_node[index].zone}  (${i.network[0].fixed_ip_v4})\n      Private IPv4: ${i.network[1].fixed_ip_v4}"
  ])}
  ======================
  EOT
}

output "ansible_inventory" {
  description = "Print Information about the created instance"
  value = <<EOT
[master]
${openstack_compute_instance_v2.master_instance.network[0].fixed_ip_v4} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=${var.private_key_path}
[workers]
${join("\n", [
  for index, i in openstack_compute_instance_v2.worker_instance : 
  "${i.network[0].fixed_ip_v4} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=${var.private_key_path}"
])}
  EOT
}

output "ansible_vars" {
  description = "Print Information about the created instance"
  value = <<EOT
  EOT
}