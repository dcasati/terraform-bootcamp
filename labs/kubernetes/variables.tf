variable "client_id" {
  default = ""
}
variable "client_secret" {
  default = ""
}

variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
  default = "k8s-mylab"
}

variable "rg_prefix" {
  description = "The shortened abbreviation to represent your resource group that will go on the front of some resources."
  default     = "rg"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  default     = "k8s"
}

variable "kubernetes_version" {
  default     = "1.10.3"
}

variable "agent_count" {
  default = "3"
}
variable "agent_vm_size" {
  default = "Standard_D2"
}

variable "dns_prefix" {
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default     = "mylab"
}


variable "admin_username" {
  default      = "ubuntu"
}


variable "ssh_public_data" {
  default     = "~/.ssh/id_rsa.pub"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "centralus"
}

