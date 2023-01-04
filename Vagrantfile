# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = "libvirt"

Vagrant.configure("2") do |config|

  config.vm.box = "kenc/arch-base"
  config.vm.box_url = "file://./builds/arch-base.json"


  config.nfs.verify_installed = false
  config.vm.synced_folder '.', '/vagrant', disabled: true
end
