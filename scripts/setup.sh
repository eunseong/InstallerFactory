#!/bin/bash

#dnf install kernel-devel vagrant VirtualBox 

wget -P /tmp https://app.vagrantup.com/eslee/boxes/prolinux8_anaconda/versions/8.2.210330/providers/virtualbox.box \
	&& vagrant box add prolinux8/installer_gen /tmp/virtualbox.box \
	&& rm -f /tmp/virtualbox.box 
	&& vagrant up
