#!/bin/bash
set -xe

source /vagrant/scripts/env
LOGDIR=$FD/logs

[[ -d $FD/logs ]] && rm -rf $LOGDIR/* 
if [ -d $WD ]; then
	read -p "Original working directory '$WD' already exist. Remove this? [y/n]: " res
	[ "$res" != "y" ] && [ "$res" != "Y" ] && exit 0
	echo "remove the file~"
	rm -rf $WD	
fi

lorax -c /etc/lorax/lorax.conf -p ProLinux --volid "ProLinux-"$DIST" Server.x86_64" -t BaseOS -v $DIST -r "ProLinux "$DIST \
	-s http://prolinux-koji-el8.tk/kojifiles/repos/dist-prolinux8-build/latest/x86_64/ \
	-s http://pldev-repo-21.tk/prolinux/$DIST/os/x86_64/BaseOS \
	-s http://pldev-repo-21.tk/prolinux/$DIST/os/x86_64/AppStream \
	--isfinal \
	$WD 
#	-s http://pldev-repo-21.tk/prolinux-dev/GoodSoftware/gs_dev_repo \

[ ! -d $LOGDIR ] && mkdir -p $LOGDIR
mv $PWD/*log $LOGDIR && mv $PWD/*txt $LOGDIR && mv $PWD/pkglists $LOGDIR
