#!/bin/bash
set -xe

source /vagrant/scripts/env
LOGDIR=$FD/logs

PROC=`uname -p`

RELEASE=$PRODUCT" "$VERSION
VARIANT="AppStream"

[[ -d $FD/logs ]] && rm -rf $LOGDIR/* 
if [ -d $WD ]; then
	read -p "Original working directory '$WD' already exist. Remove this? [y/n]: " res
	[ "$res" != "y" ] && [ "$res" != "Y" ] && exit 0
	echo "remove the file~"
	rm -rf $WD
fi

setenforce 0
lorax --product="$PRODUCT" --version="$VERSION" \
  --release="$RELEASE" --variant=$VARIANT \
  --source="http://dev-repo/prolinux/$VERSION/os/x86_64/BaseOS" \
  --source="http://dev-repo/prolinux/$VERSION/os/x86_64/AppStream" \
  --nomacboot --noupgrade --isfinal \
  --buildarch="$PROC" --volid="$VOLID" $WD
setenforce 1

[ ! -d $LOGDIR ] && mkdir -p $LOGDIR
mv $PWD/*log $LOGDIR && mv $PWD/*txt $LOGDIR && mv $PWD/pkglists $LOGDIR
