# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.

  # config.vm.box_download_insecure = true
  
  config.butcher.verify_ssl = false

  config.vm.define "rasterize" do |rasterize|
    rasterize.vm.box = "ubuntu/focal64"
    rasterize.vm.hostname = "rasterize01"
    rasterize.vm.network "public_network", ip: '192.168.1.25'
    # rasterize.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "white_network"
    # rasterize.vm.network :forwarded_port, guest: 8000, host: 8000, id: 'rrasterize'
    config.vm.provider :virtualbox do |vb|
      vb.linked_clone = true
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      # vb.customize ['modifyvm', :id, '--natnet1', '192.168.222.0/24']
      vb.customize ['modifyvm', :id, "--natdnshostresolver1", "off"]
    end
  end


  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = "./Berksfile"

  config.vm.provision "chef_zero" do |chef|
    # Specify the local paths where Chef data is stored
    chef.cookbooks_path = "../"
    # chef.data_bags_path = "data_bags"
    chef.nodes_path = "../../nodes"
    # chef.roles_path = "roles"
    #config.vm.box = "centos/8"
     
    # Add a recipe
    chef.add_recipe "remote_rasterize"

    chef.arguments = "--chef-license accept"
  end

end
