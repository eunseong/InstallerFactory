#!/bin/bash
set -xe

source env.sh
OD=/root/prolinux-8.2_GS

rm -rf $OD $FD/*log $FD/*txt;
sudo lorax -c /etc/lorax/lorax.conf -p ProLinux --volid "ProLinux-"$DIST" Server.x86_64" -t BaseOS -v $DIST -r "ProLinux "$DIST \
	-s http://prolinux-koji-el8.tk/kojifiles/repos/dist-prolinux8-build/latest/x86_64/ \
	-s http://pldev-repo-21.tk/prolinux/$DIST/os/x86_64/BaseOS \
	-s http://pldev-repo-21.tk/prolinux/$DIST/os/x86_64/AppStream \
	--isfinal \
	$OD && mv $OD $FD
#		  -s http://pldev-repo-21.tk/prolinux-dev/GoodSoftware/gs_dev_repo \