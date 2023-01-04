variable "iso_url" {
  type        = string
  description = "ISO file URL"
  default     = "https://cdimage.debian.org/debian-cd/11.5.0/amd64/iso-cd/debian-11.5.0-amd64-netinst.iso"
}

variable "iso_checksum" {
  type        = string
  description = "ISO file checksum"
  default     = "file:https://cdimage.debian.org/debian-cd/11.5.0/amd64/iso-cd/SHA256SUMS"
}

variable "vm_name" {
  type        = string
  description = "VM name"
  default     = "base"
}

variable "version" {
  type        = string
  description = "Version of box"
}

variable "headless" {
  type        = bool
  description = "Run in headless mode"
  default     = true
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
