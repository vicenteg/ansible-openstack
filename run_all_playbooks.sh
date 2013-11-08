#!/bin/sh

PUBLIC_KEY_PATH="$HOME/.ssh/id_dsa.pub"
test -f $PUBLIC_KEY_PATH || echo nope
KEY=`cat $PUBLIC_KEY_PATH`
if [ -z "$KEY" ];
then
	echo "No public key at $PUBLIC_KEY_PATH, exiting."
	exit 1
fi

ansible selab -m ping -u root -i hosts 2>&1 > /dev/null
ANSIBLE_PING_RC="$?"

if [ $ANSIBLE_PING_RC != 0 ]; then
	echo "Installing public key."
	ansible selab -m authorized_key -u root -i hosts -k -c paramiko -a "user=root key='$KEY'"
fi
ansible-playbook -i hosts -l selab site.yml
