#!/bin/bash -e
set -e
. /tmp/os_detect.sh


# Turn off DNS lookups for SSH
echo "UseDNS no" >> /etc/ssh/sshd_config

echo "Running a zyper install of dependent packages"	
zypper install -y git wget curl vim cloud-init
# sed -i -e 's/^After=systemd-networkd-wait-online.service/After=systemd-networkd-wait-online.service\nAfter=wicked.service\nRequires=wicked.service/g' /usr/lib/systemd/system/cloud-init.service
systemctl enable cloud-config cloud-final cloud-init-local cloud-init	
	

#Fix sudoers to not prompt for root password but rather user password
sed -i "s/^Defaults targetpw/#Defaults targetpw/" /etc/sudoers
sed -i "s/^Defaults targetpw/#Defaults targetpw/" /etc/sudoers
sed -i "s/^ALL   ALL=(ALL) ALL/#ALL   ALL=(ALL) ALL/" /etc/sudoers
echo 'cloud-user   ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/cloud-user;

if [[ $VAGRANT  =~ true || $VAGRANT =~ 1 || $VAGRANT =~ yes ]]; then
	echo "Checking vagrant user"
	mkdir -pm 700 /home/vagrant/.ssh
	wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
	chmod 0600 /home/vagrant/.ssh/authorized_keys
	chown -R vagrant:vagrant /home/vagrant/.ssh
fi

echo "uname -r: $(uname -r)"
if [[ $UPDATE  =~ true || $UPDATE =~ 1 || $UPDATE =~ yes ]]; then
	  echo "Running Update with Zypper"
		zypper update -y
fi
