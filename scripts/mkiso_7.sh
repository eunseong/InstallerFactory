#!/bin/bash
set -xe

source /vagrant/scripts/env
source /vagrant/scripts/log
REPO=$FD/repo/pl-$DIST
OUT=$FD/OUT_ISOs
OUT_NAME=ProLinux-$DIST.$COMMIT.iso

if [ $EUID -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi
if [ ! -d $OUT ]; then
	echo "Check installer build environment: the out_dir '$OUT' doesn't exist, then make the dir"
	mkdir -p $OUT
fi
if [ -e $OUT/$OUT_NAME ]; then
	read -p "Original ISO file '$OUT_NAME' already exist. Remove this? [y/n]: " res
	[ "$res" != "y" ] && [ "$res" != "Y" ] && exit 1
	echo "remove the file~"
	rm -f $OUT/$OUT_NAME
fi

echo -e "\n(1/5)Download and install the Installer meta files\n"
wget -P /tmp/ http://pldev-repo-21.tk/prolinux-dev/ISO_meta/pl7_generic.tar.gz \
	&& tar zxvf /tmp/pl7_generic.tar.gz --directory=$WD/ \
	&& sed -i 's/7\.x/'$DIST'/g' $WD/media.repo $WD/.treeinfo $WD/.discinfo $WD/EFI/BOOT/BOOT.conf $WD/EFI/BOOT/grub.cfg $WD/isolinux/isolinux.cfg \
	&& rm -f /tmp/pl7_generic*.tar.gz


#Copy ProLinux packages
echo -e "\n(2/5)Copy ProLinux Packages in the Installer directory\n"
if [ -d $WD/Packages/ ]; then
	echo remove Packages repo directory
	rm -rf $WD/Packages
fi
if [[ ! -d $REPO/pl7-Packages ]]; then
	echo -e "\n\nPrepare ProLinux package first!, end the image generation"
	echo -e "\tRepo download guide:"
	echo -e "\t\tdnf reposync --repoid=pl7-OS --downloaddir=$REPO --download-metadata"
	exit 1
fi
cp -rT $REPO/pl7-Packages $WD/Packages

##### For EL8 #####
#if [ -d $WD/BaseOS/ ]; then
#	echo remove BaseOS repo directory
#	rm -rf $WD/BaseOS
#fi
#if [ -d $WD/AppStream/ ]; then
#	echo remove AppStream repo directory
#	rm -rf $WD/AppStream
#fi
#if [[ ! -d $REPO/pl8-BaseOS || ! -d $REPO/pl8-AppStream ]]; then
#	echo -e "\n\nPrepare ProLinux package first!, end the image generation"
#	echo -e "\tRepo download guide:"
#	echo -e "\t\tdnf reposync --repoid=pl8-BaseOS --downloaddir=$REPO --download-metadata"
#	echo -e "\t\tdnf reposync --repoid=pl8-AppStream --downloaddir=$REPO --download-metadata"
#	exit 1
#fi
#cp -rT $REPO/pl8-BaseOS $WD/BaseOS 
#cp -rT $REPO/pl8-AppStream $WD/AppStream
##### For EL8 #####


#Reset local repository metadata
echo -e "\n(3/5)Create repository meta files\n"
if [ -d $WD/repodata ]; then
	echo remove OS repo-meta directory
	rm -rf $WD/repodata $WD/.repodata 
fi
createrepo_c -g $REPO/repodata/*comps-os.x86_64.xml $WD/


##### For EL8 #####
#if [ -d $WD/BaseOS/repodata ]; then
#	echo remove BaseOS repo-meta directory
#	rm -rf $WD/BaseOS/repodata $WD/BaseOS/.repodata 
#fi
#if [ -d $WD/AppStream/repodata ]; then
#	echo remove AppStream repo-meta directory
#	rm -rf $WD/AppStream/repodata $WD/AppStream/.repodata
#fi
#createrepo_c -g $REPO/pl8-BaseOS/repodata/*comps-BaseOS.x86_64.xml $WD/BaseOS/
#createrepo_c -g $REPO/pl8-AppStream/repodata/*comps-AppStream.x86_64.xml $WD/AppStream/
#pushd $REPO
#[[ ! -e $(echo $PWD/modules.yaml) ]] \
#	&& wget pldev-repo-21.tk/prolinux-dev/ISO_meta/modules_meta/modules-$DIST.yaml.gz \
#	&& gzip -d modules-$DIST.yaml.gz && mv modules-$DIST.yaml modules.yaml
#modifyrepo_c modules.yaml $WD/AppStream/repodata/
#popd
##### For EL8 #####


echo -e "\n(4/5)Create Installer ISO\n"
mkisofs -U -r -v -T -J -joliet-long -allow-limited-size -V "ProLinux-"$DIST" Server.x86_64" -volset "ProLinux-"$DIST" Server.x86_64" \
			-b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 \
			-boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -o $OUT/$OUT_NAME $WD/


echo -e "\n(5/5)Implant&Check md5 checksum in the ISO\n"
implantisomd5 $OUT/$OUT_NAME
checkisomd5 $OUT/$OUT_NAME

echo -e "\n\nInstaller build complete!"
echo "Installer ISO file size is" $(du -hs "$OUT"/"$OUT_NAME")
