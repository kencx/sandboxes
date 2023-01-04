# Sandboxes

A repository of custom Vagrant boxes for development and testing.

## Setup

1. Install [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
2. Install libvirt

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

4. Build box

```bash
$ cd bases/debian
$ packer build -var-file=auto.pkrvars.hcl .
$ vagrant box add ../../builds/debian_base.libvirt.box --provider libvirt --name username/debian-base
```

5. Start VM with libvirt provider

```bash
$ vagrant init username/debian-base
$ vagrant up --provider=libvirt
$ vagrant ssh
```

## References
- [packer-arch](https://github.com/elasticdog/packer-arch/)
- [bento](https://github.com/chef/bento)
