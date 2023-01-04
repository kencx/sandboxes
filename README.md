# Sandboxes

A repository of custom Vagrant qemu/libvirt boxes for development and testing.

## Setup

1. Install [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
2. Install libvirt on host

```bash
$ sudo apt install qemu libvirt-daemon-system libvirt-dev ebtables \
    libguestfs-tools ruby-libvirt libvirt-clients bridge-utils
$ sudo adduser [username] kvm
$ sudo adduser [username] libvirt
$ virsh list --all
```

3. Install Vagrant plugins

```bash
$ vagrant plugin install vagrant-libvirt
$ vagrant plugin install vagrant-mutate
```

## Automated Builds

Vagrant base boxes are built with Packer's qemu builder and Vagrant
post-processor. A build generates a custom base box in `builds/boxes`.

```bash
$ cd bases/debian
$ packer build -var-file=auto.pkrvars.hcl .
```

On each build, Packer runs a post-provisioning shell to update the box's catalog
metadata file in `builds/*_base.json` using the `update_catalog.py` script.

Create a Vagrantfile with the catalog metadata file as `config.vm.box_url` to
enable versioning:

```ruby
ENV['VAGRANT_DEFAULT_PROVIDER'] = "libvirt"

Vagrant.configure("2") do |config|
  config.vm.box = "username/debian-base"
  config.vm.box_url = "file://./builds/debian-base.json"
end
```

Start the VM

```bash
$ vagrant up
$ vagrant ssh
```

## Notes

Specify your custom SSH key pair with `ssh_private_key_file` and `ssh_public_key_file`.
The SSH public key will be added to the user's `.ssh/authorized_keys` file.

The default root password is `vagrant`. Although root login is disabled, it is
recommended to change this for non-development systems:

```hcl
# auto.pkrvars.hcl
root_password = changeme
```

or you can choose to change the root password on startup with

```bash
$ sudo passwd root
```

It is also recommmended to disable password-less sudo, which has been enabled for
easy provisioning.

## References
- [packer-arch](https://github.com/elasticdog/packer-arch/)
- [bento](https://github.com/chef/bento)
