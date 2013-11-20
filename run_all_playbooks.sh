#!/bin/sh

PUBLIC_KEY_PATH="$HOME/.ssh/id_dsa.pub"
test -f $PUBLIC_KEY_PATH || echo nope
KEY=`cat $PUBLIC_KEY_PATH`
if [ -z "$KEY" ];
then
	echo "No public key found at $PUBLIC_KEY_PATH, exiting."
	exit 1
fi

# run an ansible "ping" to test whether we can gain access to the 
# servers.
ansible openstack-cluster -m ping -u root -i hosts 2>&1 > /dev/null
ANSIBLE_PING_RC="$?"

# If we can't get access, try installing our key in authorized_keys 
# on the target servers.
if [ $ANSIBLE_PING_RC != 0 ]; then
	echo "Installing public key."
	ansible openstack-cluster -m authorized_key -u root -i hosts -k -c paramiko -a "user=root key='$KEY'"
fi

# having added the public key, perform the install.
ansible-playbook -i hosts site.yml
