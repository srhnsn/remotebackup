require "yaml"

options = File.open("vagrant.yaml").read
options = YAML.load(options)

Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/bionic64"
    config.vm.hostname = options["hostname"]

    config.vm.network :forwarded_port, guest: 22, host: 38100, host_ip: "127.0.0.1", id: "ssh"
    config.vm.network "private_network", ip: options["ip"]

    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder "provisioning", "/provisioning", :mount_options => ["ro"]
    config.vm.synced_folder options["mounts"]["settings"], "/etc/remotebackup", :mount_options => ["ro"]
    config.vm.synced_folder options["mounts"]["source"], "/source", :mount_options => ["ro"]

    config.vm.provision "shell", path: "provisioning/share/provision.sh"

    config.vm.provider "virtualbox" do |vm|
        vm.cpus = options["cpus"]
        vm.memory = options["memory_gb"] * 1024
    end
end
