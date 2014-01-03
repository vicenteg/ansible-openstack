#!/usr/bin/python

from netaddr import IPNetwork, IPAddress, IPRange

storage_device = "eth3"
mgmt_device = "eth2"
data_device = "eth1"

storage_subnet = "10.1.3.0/24"
mgmt_subnet = "10.1.1.0/24"
data_subnet = "10.1.2.0/24"
public_subnet = "192.168.142.0/24"

mgmt_range_start = '10.1.1.20'
mgmt_range_end = '10.1.1.219'

data_range_start = '10.1.2.20'
data_range_end = '10.1.2.219'

storage_range_start = '10.1.3.20'
storage_range_end = '10.1.3.219'

mgmt_network = IPNetwork(mgmt_subnet)
data_network = IPNetwork(data_subnet)
storage_network = IPNetwork(storage_subnet)

mgmt_ip_list = list(IPRange(IPAddress(mgmt_range_start), IPAddress(mgmt_range_end)))
data_ip_list = list(IPRange(IPAddress(data_range_start), IPAddress(data_range_end)))
storage_ip_list = list(IPRange(IPAddress(storage_range_start), IPAddress(storage_range_end)))

cluster = [
	"controller1",
	"controller2",
	"controller3",
	"lb1",
	"lb2",
	"compute1",
	"compute2",
	"compute3" ]

for node in cluster:
	ansible_cmd = "ansible %s -i hosts -u root -m command -a '%%s'" % node
	mgmt_if = { 
		'ip': mgmt_ip_list.pop(),
		'netmask': mgmt_network.netmask,
		'dev': mgmt_device
	}

	data_if = {
		'ip': data_ip_list.pop(),
		'netmask': data_network.netmask,
		'dev': data_device
	}

	storage_if = {
		'ip': storage_ip_list.pop(),
		'netmask': storage_network.netmask,
		'dev': storage_device
	}

        m = "ip addr add %(ip)s/%(netmask)s dev %(dev)s" % mgmt_if
        s = "ip addr add %(ip)s/%(netmask)s dev %(dev)s" % data_if
        stor = "ip addr add %(ip)s/%(netmask)s dev %(dev)s" % storage_if
        m_up = "ip link set dev %(dev)s up" % mgmt_if
        s_up = "ip link set dev %(dev)s up" % data_if
        stor_up = "ip link set dev %(dev)s up" % storage_if

	for c in (m, s, stor, m_up, s_up, stor_up):
		print ansible_cmd % c

