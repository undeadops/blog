Title: CoreOS on AWS with Ansible Part 2
Date: 2016-01-09 12:39
Category: Automation
Tags: ansible, automation, coreos, docker, aws
Slug: coreos-on-aws-ansible-part2
Authors: Mitch

###Description

Part 2 of CoreOS on AWS with Ansible, [part 1]({filename}coreos-on-aws-ansible-part1.md) discussed the CoreOS Cluster Setup.  As I was writing this, it did dawn on me that the order I'm writing these in, is probably backwards.  You would need the Security Group setup before the cluster could come up.  Sorry, but on we go.

AWS Security Groups, are "kinda" like firewalls.  Except they do not exist on the typical network boundary, they exist within the virtual layers of the network bridges between the host OS and the Virtual Machines running on it.  Its what allows EC2 instances that reside on multiple networks and separate Availability Zones to exist within the same Security Group, and thus the same access privileges.  Overall, it does make Security on AWS simpler to manage.  Then VPC's came along with the ability to put firewall ACL's on your private subnets in addition to them, and things can get pretty harry, quickly, but maybe another time.

I will again be running everything in one file, and not with a separate rules directory as is typical of Ansible play books, for simplicity.  The first part is pretty typical of an Ansible EC2 play.

```yaml

---
  - name: Configure Security Groups for AWS Infrastructure
    hosts: localhost
    gather_facts: false
    vars:
      security_group: docker-sg01
      vpc_id: vpc-1111111
      vpc_region: us-east-1
      my_ip: 10.1.1.1/32  # My Home Public IP

```

I'm using a few variables here, basically the name of the security group, region and the VPC id.  I also have a variable for my home ip address(not real of coarse), which we will use in the rules section later.  If I wanted to make this play more generic, I would probably have a list of rules as well in the vars, and just include a role that could loop over those.  However, we are just going over the basics.

The next part of this play is the setup with the `ec2_group` module for its basic required configuration.

```yaml

    tasks:
      - name: 'Provision Docker Security Group'
        local_action:
          module: ec2_group
          name: "{{ security_group }}"
          description: "CoreOS Docker Security Group"
          vpc_id: "{{ vpc_id }}"
          region: "{{ vpc_region }}"  

```

We are using the variables defined in the first section, and setting up the few requirements of the `ec2_group` module.  When first starting to us this module I did go through several iterations of this,  as the subtleties of this section matter quite a bit.  I kept getting no output or minimal output with no errors unless everything here was just right.  

Final section is the rules to apply.  There is an option not to purge current rules, but that is
counter intuitive.  Infrastructure as Code should define your infrastructure.  Which is why that option is enabled by default, and I don't have it listed because it is the correct option.  Your ansible playbook should define what you want your security group to look like.  It will be a complete view, checked into git or some other source control to be versioned, and changes can be tracked and monitored. On to the rules.

```yaml

    rules:
    - proto: tcp
      from_port: 22
      to_port: 22
      group_name: bastion-sg01  # My VPC Bastion Host Security group
    - proto: tcp
      from_port: 22
      to_port: 22
      cidr_ip: "{{ my_ip }}"
    - proto: all
      group_name: "{{ security_group }}" # To allow all coreos hosts to talk

```

And thats it.   Run this play like you would any other and it should make your security group look exactly like what is listed here, with the exception of the egress rules.  For simplicity I did not include egress_rules, because I was using the defaults.  By default I mean the `ec2_group` module sets up a default allow everything out for egress.  Which, unless I have specific security concerns, where I would need to lock this down the default is fine. 

The entire [docker-sg01.yml](https://github.com/undeadops/scripts/blob/master/ansible/docker-sg01.yml) can be downloaded from my GitHub account.  
