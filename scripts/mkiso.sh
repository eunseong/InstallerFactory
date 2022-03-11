#!/bin/bash
set -xe

source /vagrant/scripts/env
source /vagrant/scripts/log
COMMIT=8

REPO=$FD/repo/pl-$VERSION
OUT=$FD/OUT_ISOs
OUT_NAME=ProLinux-$VERSION.$COMMIT.iso
TREEDIR=/vagrant/scripts/treeinfo


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


echo -e "\n(1/5)Sets up the Installer meta files\n"
[[ -f $WD/.treeinfo ]] && rm -f $WD/.treeinfo
[[ ! -f "$TREEDIR" ]] \
		&& wget 192.168.2.244/prolinux-dev/ISO_meta/PL8_meta/.treeinfo -O $TREEDIR 
cat <<EOF > $WD/.treeinfo
$(cat $TREEDIR)
EOF
sed -i 's/#VERSION/'$VERSION'/g' $WD/.treeinfo

cat <<EOF > $WD/media.repo
[InstallMedia]
name=ProLinux $VERSION
mediaid=None
metadata_expire=-1
gpgcheck=0
cost=500
EOF


#Copy ProLinux packages
echo -e "\n(2/5)Copy ProLinux Packages in the Installer directory\n"
mkdir /tmp/repofiles && mv /etc/yum.repos.d/*repo /tmp/repofiles/
[[ -f /etc/yum.repos.d/PL_BETA_REPO.repo ]] && rm -f /etc/yum.repos.d/PL_BETA_REPO.repo 
cat <<EOF > /etc/yum.repos.d/PL_BETA_REPO.repo
[BaseOS]
name=ProLinux-$VERSION BaseOS (beta)
baseurl=http://dev-repo/prolinux/$VERSION/os/x86_64/BaseOS
gpgcheck=0

[AppStream]
name=ProLinux-$VERSION AppStream (beta)
baseurl=http://dev-repo/prolinux/$VERSION/os/x86_64/AppStream
gpgcheck=0
EOF

if [ -d $WD/BaseOS ]; then
	read -p "BaseOS repo already exists. Remove this? [y/n]: " res
	if [ "$res" == "y" ] || [ "$res" == "Y" ]; then
		echo remove BaseOS repo directory
		rm -rf $WD/BaseOS
		dnf reposync --repoid=BaseOS --downloaddir=$WD --download-metadata
	fi
else
	dnf reposync --repoid=BaseOS --downloaddir=$WD --download-metadata
fi
echo -e "\n"
if [ -d $WD/AppStream ]; then
	read -p "AppStream repo already exists. Remove this? [y/n]: " res
	if [ "$res" == "y" ] || [ "$res" == "Y" ]; then
		echo remove AppStream repo directory
		rm -rf $WD/AppStream
		dnf reposync --repoid=AppStream --downloaddir=$WD --download-metadata
	fi
else
	dnf reposync --repoid=AppStream --downloaddir=$WD --download-metadata
fi
rm -f /etc/yum.repos.d/PL_BETA_REPO.repo
mv /tmp/repofiles/*repo /etc/yum.repos.d/ && rmdir /tmp/repofiles 


echo -e "\n(3/5)Create Installer ISO\n"
mkisofs -o $OUT/$OUT_NAME \
	-J -R -l -v \
	-joliet-long -jcharset utf-8 -graft-points \
	-b isolinux/isolinux.bin \
   	-c isolinux/boot.cat -no-emul-boot \
	-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
	-e images/efiboot.img -no-emul-boot \
	-V "$VOLID" \
   	$WD/


echo -e "\n(4/5)Implant&Check md5 checksum in the ISO\n"
implantisomd5 $OUT/$OUT_NAME
checkisomd5 $OUT/$OUT_NAME


echo -e "\n(5/5)Set the media as a bootable ISO\n"
isohybrid $OUT/$OUT_NAME

echo -e "\n\nInstaller build complete!"
echo "Installer ISO file size is" $(du -hs "$OUT"/"$OUT_NAME")
