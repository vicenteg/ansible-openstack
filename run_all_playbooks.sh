#!/bin/sh

trap "echo Stopping; exit" SIGHUP SIGINT SIGTERM


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
ansible openstack_cluster -m ping -u root -i hosts 2>&1 > /dev/null
ANSIBLE_PING_RC="$?"

# If we can't get access, try installing our key in authorized_keys 
# on the target servers.
if [ $ANSIBLE_PING_RC != 0 ]; then
	echo "Installing public key."
	ansible openstack_cluster -m authorized_key -u root -i hosts -k -c paramiko -a "user=root key='$KEY'"
fi

# It's the final countdown!
echo "Ready to begin in T-10 seconds."
for i in `seq 1 10 | sort -rn `; do echo -n "$i "; sleep 1; done

# having added the public key, perform the install.
ansible-playbook -i hosts playbooks/site.yml 

# if the above succeeded, poll the servers using a ping before 
# continuting on to the test playbook.
if [ "$?" == 0 ]; then
	while :;
	do
	  ansible openstack_cluster -m ping -u root 
	  [ "$?" -eq 0 ] && break
	  sleep 2
	done

	# do some quantum, nova operations to validate the basic env
	if [ "$?" == 0 ]; then
		time ansible-playbook -i hosts playbooks/test.yml
	fi
fi
