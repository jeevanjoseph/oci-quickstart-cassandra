#!/bin/bash
set -e -x

# Patch the instance
sudo yum update -y

# Install Java and a few other tools
sudo yum install java mdadm screen dstat -y

# Create a RAID 6 array across all 9 NVMe drives, create an XFS filesystem on the array and mount the filesystem
sudo mdadm --create /dev/md0 --chunk=256 --raid-devices=9 --level=6 /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1 /dev/nvme5n1 /dev/nvme6n1 /dev/nvme7n1 /dev/nvme8n1
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm.conf >> /dev/null
sudo mkfs.xfs -s size=4096 -d su=262144 -d sw=6 /dev/md0
sudo mkdir /mnt/cassandra
sudo mount /dev/md0 /mnt/cassandra

# Open up the operating system firewall to allow Cassandra to communicate between instances. We limit communication on the Cassandra ports to the VCN subnet.
sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="${vcn_cidr}" port protocol="tcp" port="7000-7001" accept'
sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="${vcn_cidr}" port protocol="tcp" port="7199" accept'

# Add the DataStax repo, using yum to install Cassandra
echo -e "[DataStax]\nname=DataStax Repo for Apache Cassandra\nbaseurl=http://rpm.datastax.com/datastax-ddc/3.2\nenabled=1\ngpgcheck=0" | sudo tee /etc/yum.repos.d/datastax.repo
sudo yum update -y
sudo yum install datastax-ddc -y

# Set the cluster name, use the NVMe backed filesystem for data, and a few more details
sudo chown cassandra.cassandra /mnt/cassandra/
sudo sed -i "10s/.*/cluster_name: '${cluster_name}'/" /etc/cassandra/conf/cassandra.yaml
sudo sed -i "71s/.*/hints_directory: \/mnt\/cassandra\/hints/" /etc/cassandra/conf/cassandra.yaml
sudo sed -i "170s/.*/    - \/mnt\/cassandra\/data/" /etc/cassandra/conf/cassandra.yaml
sudo sed -i "175s/.*/commitlog_directory: \/mnt\/cassandra\/commitlog/" /etc/cassandra/conf/cassandra.yaml
sudo sed -i "287s/.*/saved_caches_directory: \/mnt\/cassandra\/saved_caches/" /etc/cassandra/conf/cassandra.yaml
sudo sed -i '343s/.*/          - seeds: "${private_ips}"/' /etc/cassandra/conf/cassandra.yaml
sudo sed -i "472s/.*/listen_address: ${local_private_ip}/" /etc/cassandra/conf/cassandra.yaml
sudo sed -i "801s/.*/endpoint_snitch: GossipingPropertyFileSnitch/" /etc/cassandra/conf/cassandra.yaml

# Create the Cassandra cluster
sudo rm /etc/cassandra/conf/cassandra-topology.properties
sudo sed -i "s/dc=.*/dc=AD${node_index}/g" /etc/cassandra/conf/cassandra-rackdc.properties
sudo sed -i "s/rack=.*/rack=RAC1/g" /etc/cassandra/conf/cassandra-rackdc.properties

# Start the Cassandra cluster
sudo service cassandra start
