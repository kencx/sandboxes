locals {
  iso_url        = "${var.mirror_url}{{ isotime \"2006.01\" }}.01/archlinux-{{ isotime \"2006.01\" }}.01-x86_64.iso"
  iso_checksum   = "file:${var.mirror_url}{{ isotime \"2006.01\" }}.01/sha256sums.txt"
  ssh_public_key = file(var.ssh_public_key_path)
  build_time     = "${formatdate("YYYY-MM-DD", timestamp())}"
}

source "qemu" "arch_base" {
  vm_name          = var.vm_name
  headless         = var.headless
  shutdown_command = "sudo /sbin/shutdown -hP now"

  iso_url      = local.iso_url
  iso_checksum = local.iso_checksum

  cpus      = 1
  disk_size = "10000"
  memory    = 1024
  qemuargs = [
    ["-m", "1024M"],
    ["-bios", "bios-256k.bin"]
  ]

  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_private_key_file = var.ssh_private_key_path
  ssh_port             = 22
  ssh_wait_timeout     = "3600s"

  http_directory = "http"
  boot_wait      = "5s"
  boot_command = [
    "<enter><wait10><wait10><wait10><wait10><wait10><wait10>",
    "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/pre-install.sh<enter><wait5>",
    "/usr/bin/bash ./pre-install.sh<enter>"
  ]
}

build {
  sources = ["source.qemu.arch_base"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "./bin/install.sh",
      "./bin/minimize.sh",
    ]
    environment_vars = [
      "TIMEZONE=Asia/Singapore",
      "LOCALE=en_US.UTF-8",
      "HOSTNAME=arch.vagrantup.com",
      "ROOT_PASSWORD=${var.root_password}",
      "SSH_USER=${var.ssh_username}",
      "SSH_PASSWORD=${var.ssh_password}",
    ]
    expect_disconnect = true
  }

  post-processors {
    post-processor "vagrant" {
      output = "../../builds/boxes/{{ .BuildName }}.{{ .Provider }}.${build_time}.box"
    }

    post-processor "checksum" {
      checksum_types = ["sha256"]
      output = "../../builds/boxes/{{ .BuildName }}.{{ .ChecksumType }}"
    }

    post-processor "shell" {
      script = "../../update_catalog.py"
      execute_command = "{{ .Vars }} /bin/bash -c {{ .Script }}
        -f ../../builds/arch-base.json
        -v ${var.version}
        -p libvirt
        -b ../../builds/boxes/{{ .BuildName }}.libvirt.${build_time}.box
        -t sha256
        -c file://../../builds/boxes/{{ .BuildName }}.sha256"
    }
  }
}
