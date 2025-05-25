# module "deploy_master" {
#   source                 = "github.com/numtide/nixos-anywhere//terraform/all-in-one"
#   nixos_system_attr      = "../nix/.#nixosConfigurations.${var.nixos-init-system}.config.system.build.toplevel"
#   nixos_partitioner_attr = "../nix/.#nixosConfigurations.${var.nixos-init-system}.config.system.build.diskoScriptNoDeps"
#   debug_logging          = true
#   target_user            = "ubuntu"
#   instance_id            = openstack_compute_instance_v2.master_instance.id
#   target_host            = openstack_compute_instance_v2.master_instance.network[0].fixed_ip_v4
#   target_port            = 22
#   install_ssh_key        = file(var.private_key_path)
# }