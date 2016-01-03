Title: CoreOS on AWS with Ansible Part 1
Date: 2016-01-02 23:32
Category: Automation
Tags: ansible, automation, coreos, docker, aws
Slug: coreos-on-aws-ansible-part1
Authors: Mitch

Description
-------

I Promised I would do some follow-ups on "Infastructure as Code".  This is a 2 part write up on the subject.

First a quick note or two about how I run Ansible with AWS.  I don't include AWS keys in my playbooks EVER.  I rely on my config of the AWS CLI which is under ~/.aws/config and ~/.aws/credentials.  Look up how to get that configured and tested before preceding here.

On with some of the variables in the playbook.  They should all be self explanatory, but obviously will need to be changed to match your environment.  Namely the `key_name`, `region`, `iam_role` and the `subnet_id`.  All need to match up with your environment.  

```yaml
---
  - name: Create CoreOS Cluster on aws
    hosts: localhost
    gather_facts: False
    vars:
      name: coreos-test-public # Yes 4 boxes named this. Why? because cattle!
      security_group: docker-sg01 # Name of Security Group to Add Instances to
      role: docker-coreos-cluster1 # Role Tag assigned to each instance
      key_name: default  # SSH Key name from AWS
      instance_type: t2.medium  # Instance Type
      region: us-east-1  # AWS Region
      image: ami-cbfdb2a1  # Stable CoreOS Image ID from time of writing
      iam_role: linux # Role from IAM Roles
      subnet_id: subnet-12345ef # Subnet ID from VPC
      count: 4  # Number of CoreOS instances
      ebs_optimized: false # Because t2.medium is not EBS optimized
```

All of these settings should be well known as options for creating an AWS instance.  The ec2 module has two options that are not passed to AWS. First is the `count` variable I used for the modules `exact_count` option, and the accompanying `count_tag`.  These two options are what makes this one play spin up 4 (or any number of `count`) CoreOS instances, all based on the instance tag named `role`.  Pretty cool feature.  Yes, they are all going to have the same "name".  However, the main tenant of cloud computing, they're cattle not pets.  It matters very little, and you shouldn't be connecting to these boxes individually anyway.

One of the cool things I like about the Ansible ec2 module is how simple it is to attach and size up disks.  In the play, I've defined two disks, one is the root disk, an 8G root volume.  CoreOS is actually pretty tiny, under 100MB in size, but the AMI snapshot size requires 8G.  Second disk is for holding the Docker container images. Which will be another point I will show how that gets setup later in the post with the cloud config.  Both drives here are defined as generic SSD. Because, why not?

```yaml
volumes:
  - device_name: /dev/xvda
    volume_type: gp2
    volume_size: 8
    delete_on_termination: True
  - device_name: /dev/xvdf
    volume_type: gp2
    volume_size: 50
    delete_on_termination: True
```

On to some more cool bits about this play, the cloud config!  The base cloud config was pulled straight from CoreOS' page on setting up with AWS.  I made a modification that allows it to handle the second EBS disk I attached in the instance config.  I format that second disk with BTRFS, and mount it at `/var/lib/docker`.  That section is as follows:

```yaml
units:
  - name: format-ebs.service
    command: start
    content: |
      [Unit]
      Description=Formats the EBS volume attached
      After=dev-xvdf.device_name
      Requires=dev-xvdf.device
      [Service]
      Type=oneshot
      RemainAfterExit=yes
      ExecStart=/usr/sbin/wipefs -f /dev/xvdf
      ExecStart=/usr/sbin/mkfs.btrfs -f /dev/xvdf
  - name: var-lib-docker.mount
    command: start
    content: |
      [Unit]
      Description=Mount EBS to /var/lib/docker
      Requires=format-ebs.service
      After=format-ebs.service
      Before=docker.service
      [Mount]
      What=/dev/xvdf
      Where=/var/lib/docker
      Type=btrfs
```

Main points in this, is that the disk as I attached it to /dev/xvdf, format the disk with btrfs, and mount it under the typical mount point of docker images, /var/lib/docker.  

With this play, spinning up a CoreOS cluster on AWS is completely hands off.  You can view the entire play in my scripts repo on GitHub at  [coreos-on-aws.yml](https://github.com/undeadops/scripts/blob/master/ansible/coreos-on-aws.yml).  Next up will be a play configuring the Security Group for these CoreOS instances.
