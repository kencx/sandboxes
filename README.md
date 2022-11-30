## Vagrant Boxes

## Setup

1. Install Vagrant
2. Install libvirt

```bash
$ sudo apt install qemu libvirt-daemon-system libvirt-dev ebtables \
    libguestfs-tools ruby-libvirt libvirt-clients bridge-utils
$ sudo adduser [user] kvm
$ sudo adduser [user] libvirt
$ virsh list --all
```

3. Install Vagrant plugins

```bash
$ vagrant plugin install vagrant-libvirt
$ vagrant plugin install vagrant-mutate
```

4. Build box

```bash
$ cd debian_base
$ packer build -var-file=auto.pkrvars.hcl .
$ vagrant box add builds/base.libvirt.box --provider libvirt --name test/base
```

5. Start VM with libvirt provider

```bash
$ vagrant init test/dbase
$ vagrant up --provider=libvirt
$ vagrant ssh
```
