##########################
#     OVH Credential     #
##########################

variable "ovh_application_key" {
  description = "the application key"
  type        = string
  default     = null
}

variable "ovh_application_secret" {
  description = "the application secret"
  type        = string
  default     = null
}

variable "ovh_consumer_key" {
  description = "the consumer key"
  type        = string
  default     = null
}

################################
#     Project Settings     #
################################

variable "region" {
  description = "Name of the OVH region to deploy"
  type        = string
  default     = "GRA9"
}

# variable "service_name" {
#   description = "Name of the vRack in OVH"
#   type        = string
#   default     = "pn-1229213"
# }

# variable "project_id" {
#   description = "Name of the cloud project in OVH"
#   type        = string
#   default     = "b36d0da37c134b62906b8985722fef66" # Remplacez OS_TENANT_ID par votre Project Tenant ID
# }

variable "project" {
  description = "Project Name"
  type        = string
  default     = "doodle" # Remplacez OS_TENANT_ID par votre Project Tenant ID
}

variable "public_key_path" {
  description = "Path to public key file to use to connect to remote instance"
  type        = string
  default     = "/home/titouan/.ssh/Olenixen_id_ed25519.pub"
}

variable "private_key_path" {
  description = "Path to private key file to use to connect to remote instance, used to install nixos with terraform"
  type        = string
  default     = "/home/titouan/.ssh/Olenixen_id_ed25519"
}

variable "nixos-init-system" {
  description = "System to use for nixos-anywhere to deploy"
  type        = string
  default     = "vm-init-x86_64-linux"
}

