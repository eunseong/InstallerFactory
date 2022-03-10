# -*- mode: ruby -*-
# vi: set ft=ruby :

#NAME = ENV['NAME'].to_s.strip.empty? ? 'eunseong-lee'.freeze : ENV['NAME'].to_s
CPU = ENV['CPU'].to_s.strip.empty? ? 8 : ENV['CPU'].to_i
MEMORY = ENV['MEMORY'].to_s.strip.empty? ? 8 : ENV['MEMORY'].to_i

Vagrant.configure("2") do |config|
  config.vm.box = "prolinux8/installer_gen"
#  config.vm.hostname = NAME
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = CPU
    vb.memory = MEMORY * 1024
  end

  config.vm.provision "shell", inline: <<-SHELL
  	echo "alias 'cwd'=/vagrant/InstallerFactory/" >> /home/vagrant/.bashrc
	source $HOME/.bashrc
  SHELL
end
