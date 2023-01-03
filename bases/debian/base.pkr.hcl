locals {
  preseed = {
    username      = var.ssh_username
    password      = var.ssh_password
    root_password = var.root_password
  }
  ssh_public_key = file(var.ssh_public_key_path)
}

source "qemu" "debian_base" {
  vm_name          = var.vm_name
  headless         = true
  shutdown_command = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  cpus      = 2
  disk_size = "10000"
  memory    = 1024
  qemuargs = [
    ["-m", "1024M"],
    ["-bios", "bios-256k.bin"],
    ["-display", "none"]
  ]

  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_private_key_file = var.ssh_private_key_path
  ssh_port             = 22
  ssh_wait_timeout     = "3600s"

  http_content = {
    "/preseed.cfg" = templatefile("${path.root}/http/preseed.pkrtpl", local.preseed)
  }
  boot_wait    = "5s"
  boot_command = ["<esc><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=us <wait>keyboard-configuration/xkb-keymap=us <wait>netcfg/get_hostname={{ .Name }} <wait>netcfg/get_domain=vagrantup.com <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>grub-installer/bootdev=default <wait><enter><wait>"]
}

build {
  sources = ["source.qemu.debian_base"]

  # vagrant setup
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts = [
      "./bin/vagrant.sh",
      "./bin/minimize.sh"
    ]
    expect_disconnect = true
  }

  post-processors {
    post-processor "vagrant" {
      output = "../../builds/{{ .BuildName }}.{{ .Provider }}.${formatdate("YYYY-MM-DD", timestamp())}.box"
    }
  }
}
