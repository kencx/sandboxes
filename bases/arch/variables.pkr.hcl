variable "mirror_url" {
  type        = string
  description = "Arch ISO Mirror URL"
  default     = "https://geo.mirror.pkgbuild.com/iso/"
}

variable "vm_name" {
  type        = string
  description = "VM name"
  default     = "arch"
}

variable "headless" {
  type        = bool
  description = "Run in headless mode"
  default     = false
}

variable "root_password" {
  type        = string
  description = "Root password"
  default     = "vagrant"
}

variable "ssh_username" {
  type        = string
  description = "SSH username"
  default     = "vagrant"
}

variable "ssh_password" {
  type        = string
  description = "SSH password"
  default     = "vagrant"
}

variable "ssh_public_key_path" {
  type        = string
  description = "SSH Public Key Path"
  default     = "~/.ssh/vagrant.pub"
}

variable "ssh_private_key_path" {
  type        = string
  description = "SSH Private Key Path"
  default     = "~/.ssh/vagrant"
}
