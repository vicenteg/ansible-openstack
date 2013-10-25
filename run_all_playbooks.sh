KEY=`cat ~/.ssh/id_dsa.pub ` 

if [ -z "$KEY" ] && exit 1

ansible selab -m authorized_key -u root -i hosts -k -c paramiko -a "user=root key='$KEY'"
ansible-playbook -i hosts -l selab site.yml
