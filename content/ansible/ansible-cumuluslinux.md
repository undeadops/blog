Title: Ansible and Cumulus Linux
Date: 2015-02-07 11:12
Category: Automation
Tags: ansible, automation, cumuluslinux
Slug: ansible-cumulus-linux
Authors: Mitch


Description
-------

I don't get around to writing these nearly enough.  At work I got my hands on a pair of switchs from [Penguin Computing](http://www.penguincomputing.com/products/network-switches/).  They're whitebox switches running [Cumulus Linux](http://cumulusnetworks.com/).  Which is, as they describe it, not based on Linux, it IS Linux.  Making me fully right at home.  Cumulus Networks has done really well being part of the automation scene since they're inception.  They have written modules for [Ansible](https://github.com/CumulusNetworks/cumulus-linux-ansible-modules) and [Puppet](https://github.com/CumulusNetworks/puppet-netdev-stdlib-cumulus-linux) to make configuring their switches easier.  Which I will be utilizing in this post.

Goals
-----

* Setup base configuration on switch
* Setup persitance across OS upgrades
* Upgrade Switch to CumulusLinux 2.5.0
 
This will required that your ansible.cfg file has included the Library directory of the CumulusLinux Modules.

Base Ansible Directory
----

    :::shell
    .
    ├── ansible.cfg
    ├── configure.yml
    ├── group_vars
    │   ├── all
    │   └── rack-3
    ├── hosts
    ├── LICENSE
    ├── README.md
    ├── roles
    │   ├── common
    │   │   ├── files
    │   │   │   └── backups
    │   │   ├── tasks
    │   │   │   └── main.yml   
    │   │   └── templates  method of implementing vlans
    │   │       ├── hostname.j2
    │   │       ├── hosts.j2
    │   │       └── motd.j2
    │   ├── interfaces
    │   │   └── tasks
    │   │       └── main.yml
    │   └── upgrade_sw
    │       └── tasks
    │           └── main.yml
    └── upgrade-switch.yml 

Quick run through of the important bits.  I haven't done any massive deployments but my plans for deployment are based on
Racks, and I haven't quite figured out a good DRY method for handling VLANs in these files so, if you know of a better way
would love to hear it.

I have an ansible.cfg file in this directory so I can add an include for having the CumulusLinux modules in the same directory. I also have kept my roles fairly plain and all varibles are in the group_vars files or in the playbook.

A quick run through of the roles that are performed.


Role: common
----
 
    ::::yaml
    ---

    - name: Create directory on persistant store
      file: path=/mnt/persist/etc state=directory mode=0755 owner=root group=root

    - name: Verify directory exists in etc
      file: path=/mnt/persist/etc/{{ item }} mode=0755 owner=root group=root state=directory
      with_items: [cron.daily]

    - name: Remove Hourly Cron from persistant store
      file: path=/mnt/persist/etc/cron.daily/backups state=absent

    - name: Cron copy of files to persistant storage
      copy: src=backups dest=/etc/cron.daily/backups mode=0755 owner=root group=root

    - name: Configure hosts file
      template: src=hosts.j2 dest=/etc/hosts mode=0644 owner=root group=root

    - name: Configure Hostname file
      template: src=hostname.j2 dest=/etc/hostname mode=0644 owner=root group=root

    - name: configure MOTD
      template: src=motd.j2 dest=/etc/motd

    - name: license switch
      cl_license: >
          src="http://{{ cl_license_server }}/cumuluslinux/license/{{ ansible_hostname }}.lic"
          restart_switchd=yes

    - name: disable arp filter
      sysctl: name=net.ipv4.conf.all.arp_filter value=0 state=present reload=yes


Stepping through this is pretty basic.  CumulusLinux switches create a mount under /mnt/persist that remains through firmware upgrades.  It also like most network gear has a dual root setup incase one OS becomes unbootable.  That directory remains and is copied over the top of the upgraded OS root after the upgrade image is laid down.  So your persistent settings need to be copied to /mnt/persist.  Which is what the bulk of the role is doing.  Including setting up a daily cronjob to perform that backup.  

One more piece however, is the inclusion of the license to the switch as all Cumulus Linux switches are licensed per the type of ports they are(1Gb,10Gb,40Gb,etc).  I host this off an internal webserver accessible by the switches, with the host variable defined in 'group_vars/all'.  This is also the place for a few other gems, like the firmware image used for the software upgrade, as well as a minimal Zero Touch Provisioning script that copies over my ssh keys.  But before I get into that part, we'll take a quick look at how the interfaces are configured on the switch as well as that firmware upgrade process.


Role: interfaces
----


    ::::yaml
    ---

    - name: configure L2/L3 interfaces on switch
      cl_interface:
        ifaceattrs: "{{ item.value }}"
        name: "{{ item.key }}"
        applyconfig: 'yes'
      with_dict: interfaces[ansible_hostname]


This was taken straight from the docs for the Cumulus Linux modules and it does the job quite well.  The core of how vlans get created and assined to interfaces is done in the 'group_vars/rack-3' variable file.  basic syntax is an interface without a .vlanid would be untagged and an interface with it, is tagged.

Quick example from that file looks like:


    ::::yaml
    ---
    interfaces:
      ex-r3-sw01:
        vlan100:
            alias: 'Host'
            bridgeports: [swp1.100,swp3-15, swp47.100, swp48.100]
        vlan110:
            alias: 'Service'
            bridgeports: [swp1.110,swp3-15.110, swp47.110, swp48.110]
        vlan140:
            alias: 'Cloud'
            bridgeports: [swp3-15.140]
        vlan199:
            alias: 'Public'
            bridgeports: [swp1.199,swp3-15.199, swp47.199]
        swp1:
            mtu: 9216
        swp2:
            mtu: 9216


Here you can see I'm setting up vlans 100,110,140, and 199 on switch ex-r3-sw01.  Giving them a description via 'alias', and bridging ports together to tie them to those vlans via either tagged or untagged interfaces.  


Role: upgrade_sw
----


    ::::yaml
    ---
    - name: Run one last backup before firmware update
      shell: bash /etc/cron.hourly/backups

    - name: upgrade cumulus linux software.
      cl_img_install: src="http://{{ cl_license_server }}/cumuluslinux/firmware/CumulusLinux-{{cl_version}}-powerpc.bin" switch_slot=yes
      register: reboot_switch

    - name: reboot switch
      shell: reboot
      when: reboot_switch.changed == True

    - name: wait for the switch to come back
      local_action: wait_for host={{ inventory_hostname }} port=22 state=stopped
      when: reboot_switch.changed == True

    - name: wait for cumulus switch to boot and respond to port 22
      local_action: wait_for host="{{ inventory_hostname }}" port=22 delay=30 search_regex=OpenSSH timeout=600
      when: reboot_switch.changed == True

This was pulled from the docs as well, but I believe it had some typo's in it.  The trick to it was in the last two plays. The documentation didn't show "inventory_hostname" as a variable, and it also needed to resolve via DNS, and not via a SSH alias as is the typical case for alot of what I do.  So your experience may vary depending, but thats what I ran into.

You will notice that I have again used a variable for the license server to be able to download the variable defined version of CumulusLinux.  Which is defined in the upgrade-switch.yml playbook.


Outside Infrastructure
----

On the network I've placed the management interfaces for these switchs, also has a server I use for alot of other management purposes that runs a small scope of DHCP addresses as well as an Apache Webserver.  Its this server that I use to serve the Zero Touch Provisioning, Firmware, and Licenses for the Cumulus Linux Switches.

The important bits of the ISC DHCP Server config is as follows:


    ::::bash
    host ex-r3-sw01 {
        hardware ethernet 6c:64:1a:00:00:01;
        server-name "ex-r3-sw01.example.com";
        option host-name "ex-r3-sw01.example.com";
        fixed-address 10.18.90.245;
    }

   host ex-r3-sw02 {
        hardware ethernet 6c:64:1a:00:00:02;
        server-name "ex-r3-sw02.example.com";
        option host-name "ex-r3-sw02.example.com";
        fixed-address 10.18.90.246;
   }

   subnet 10.18.90.0 netmask 255.255.255.0 {
      range 10.18.90.242 10.18.90.244;
      option routers 10.18.90.1;
      option cumulus-provision-url "http://10.18.90.40/cumuluslinux/basic.sh";
   }


This provides the bits for the Zero Touch Provisioning used by Cumulus Linux.  And again, points it back to this same license server.

This base.sh script is pretty basic, CumulusLinux allows the use of Bash,Perl,Python, and Ruby to configure the switch initiall.  My
usecase for this is pretty basic.  I just want my SSH keys on the host, so thats all it does.  It looks like this:

    ::::bash
    #!/bin/bash

    function error() {
      echo -e "\e[0;33mERROR: The Zero Touch Provisioning script failed while running the command $BASH_COMMAND at line $BASH_LINENO.\e[0m" >&2
      exit 1
    }
    trap error ERR

    URL="http://10.18.90.40/cumuluslinux/ansible_authorized_keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    chown root:root /root/.ssh

    /usr/bin/wget -O /root/.ssh/authorized_keys $URL

    #CUMULUS-AUTOPROVISIONING
    exit 0

The 'ansible_authorized_keys' file looks just like you would expect... if you have a host with working ssh keys copy that file and name it ansible_authorized_keys and it will work just the same.

Summary
----

Well thats the bulk of whats going on with my Ansible provisioning of a Cumulus Linux switch.  All-in-all I love the simplicity of the switch and performance is on par with anything else I've used, and I'm excied for the simplicity this will bring in configuration and setup of my Top of Rack Switches.  The entirety of these ansible playbooks is available on my github page [here](https://github.com/metaRx/ansible-network).  Many Thanks to [Cumulus Networks](http://cumulusnetworks.com) for providing the [Ansible](http://www.ansible.com/home) modules to make this as easy as it is.
