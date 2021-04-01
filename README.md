# InstallerFactory for ProLinux8 (IFP)
IFP uses vagrant image for creating the anaconda install images

## Getting prepared
- Download [vagrant installer](https://www.vagrantup.com/downloads) for your operating system, then install
- Download [Virtualbox installer](https://www.virtualbox.org/wiki/Downloads) for your operating system, then install
- Disk space recommendation: at leat 50G for IF guest
 
## Repo Sync example
```shell
cat <<EOF > /etc/yum.repos.d/PL_REPO.repo
[pl8-BaseOS]
name=ProLinux-8.2 BaseOS
baseurl=http://pldev-repo-21.tk/prolinux/8.2/os/x86_64/BaseOS
gpgcheck=0

[pl8-AppStream]
name=ProLinux-8.2 AppStream
baseurl=http://pldev-repo-21.tk/prolinux/8.2/os/x86_64/AppStream
gpgcheck=0
EOF

reposync --repoid=pl8-BaseOS --downloaddir=/vagrant/repo/pl-$DIST/ --download-metadata
reposync --repoid=pl8-AppStream --downloaddir=/vagrant/repo/pl-$DIST/ --download-metadata
```
