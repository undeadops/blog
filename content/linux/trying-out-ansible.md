Title: Trying out Ansible
Date: 2014-07-19 12:11
Category: Linux
Tags: draft, ansible, devops, automation, configuration management
Slug: trying-out-ansible
Authors: Mitch

So, I've been using [SaltStack](http://saltstack.com) for quite a while... and while I like it, I find it doesn't do everything that I want it to do.  Case in point... I have a group of webservers and I run nginx for a load balancer.  How can I dynamically add servers in the webservers group into the backend definition on the nginx load balancer config?  Haven't seen a clean/easy way to handle this in SaltStack, but [Ansible](http://www.ansible.com) handles it easily.

Ansible
-------

Ansible is a configuration management, written in [Python](http://python.org), and uses SSH instead of a client on my managed nodes.  Since I work in somewhat of an [MSP](http://en.wikipedia.org/wiki/Managed_services) type of environment.  I would prefer to leave no trace on the systems I mange.  Ansible provides that, as it cleans up after itself after a deployment. 

One of the common deployment scenarios I have is for copying over my teams SSH keys, and setting up some basic monitoring with munin and nagios (however, if you've followed my blog, you'd know I'm not real [found](|filename|../monitoring/no-fan-monitoring.md) of them).  All of The files mentioned here can be found on my [GitHub](https://github.com/metaRx/ansible-demo) page. Here we go

First, my directory layout, then I'll show the contents of the files.

    :::console
    .
    ├── authorized.yml
    ├── hosts
    ├── LICENSE
    ├── README.md
    ├── roles
    │   ├── common
    │   │   ├── files
    │   │   │   └── 01-AnsibleManaged
    │   │   └── tasks
    │   │       └── main.yml
    │   └── munin
    │       ├── handlers
    │       │   └── main.yml
    │       ├── tasks
    │       │   └── main.yml
    │       └── templates
    │           ├── munin.conf.jinja
    │           └── munin-node.conf.jinja
    └── site.yml


Ansible directory/file layouts are somewhat fixed, but I believe it works out well.  For readability and maintainability. 

First I'm going to start with the hosts file.  Again, because I work in somewhat of a MSP type of environment, having the typical /etc/ansible/hosts file isn't a good solution for me.  Ansible however, allows me to pass in environment details at runtime.  So, my whole site run for a client would be ran like:

    :::console
    $ ansible-playbook -i hosts site.yml

Going forward I need to look at this type of setup.  And I may make is so I would just have client specific hosts files along with a site specific site.yml file, but everything else could all share the same roles directories and so on.  Just make the roles generic enough that site variables will change them up for their specific needs.

On with the Ansible config.

Filename: hosts

    :::ini
    # Inventory file
    [webservers]
    test-web01  ansible_ssh_user=ubuntu
    test-web02  ansible_ssh_user=ubuntu

    [lbservers]
    test-lb     ansible_ssh_user=ubuntu

    [prodservers:children]
    webservers
    lbservers
   
    [prodservers:vars]
    munin_master=False
    
    [master]
    test-master ansible_ssh_user=ubuntu munin_master=True

This file describes the groups, and individual hosts that are part of those groups.  This file also includes some variables.  One of a couple different ways environment variables can be applied to hosts in a group.  Typically I might also have the IP address of the host if I require that to connect to it, but in order to keep this file simple, I've added those to my local hosts file(/etc/hosts).

You can test connectivity with a ping via Ansible:

    :::console
    $ ansible -i hosts all -m ping
    test-web01 | success >> {
        "changed": false,
        "ping": "pong"
    }
    
    test-master | success >> {
        "changed": false, 
        "ping": "pong"
    }
    
    test-lb | success >> {
        "changed": false, 
        "ping": "pong"
    }
    
    test-web02 | success >> {
        "changed": false, 
        "ping": "pong"
    }


Looks good, Lets move on to our site.

Filename: site.yml

    :::yaml
    ---
    - name: apply common configuration to all nodes
      hosts: all
      user: ubuntu
      gather_facts: yes
      sudo: yes
      vars:
        munin_master_ip: 10.11.0.68
      roles:
        - common
        - ntp
        - munin
        - nagios-nrpe

Pretty basic stuff, it applies to all hosts, now we can look at what its doing.

The variable "munin_master_ip" will come into play in a bit, but for now lets look at what common and ntp are doing real quick.

I use common as a generic set of things I like applied to a host, from some standard applications I like installed on all of my hosts, to a few
configuration things.

Here goes:

Filename: roles/common/tasks/main.yml

    :::yaml
    ---

    - name: Install commonly used packages
      apt: pkg={{ item }} state=present
      with_items:
          - htop
          - screen
          - zsh
          - vim
          - iftop

    - name: Ansible Managed MOTD
      copy: src=01-AnsibleManaged dest=/etc/update-motd.d/01-AnsibleManaged mode=0755 owner=root group=root

And for the contents of the managed file:

Filename: roles/common/files/01-AnsibleManaged

    :::bash
    #!/bin/sh 

    printf "### ANSIBLE MANAGED HOST - CHANGES MAY BE OVERWRITTEN ###\n"

Simply, this is a set of genaric system setup... Things I want consistently configured a particular way. For simplicity sake, I'm just doing two things here.  Installing some packages and pushing a script that Ubuntu uses to dynically update the MOTD.

On to Munin.  The above has been somewhat of a primer and barely touches the surface of what Ansible is capable of.  The ease in which ansible can relate and link to other managed systems is something I found most impressive and something lacking in other configuration management system.  Not to say they can't do it, its just not a built-in and obvious capability, where in Ansible it is.  On to the configuration file:

Filename: roles/munin/tasks/main.yml

    :::yaml
    ---
  
    # Ensure munin-node is installed
    - name: Ensure munin-node package is installed
      apt: pkg=munin-node state=installed

    - name: Install Munin-Node and Munin Master Node
      apt: pkg={{ item }} state=installed
      when: munin_master
      with_items:
          - munin
          - munin-node

    - name: copy over munin-node.conf
      template: src=munin-node.conf.jinja dest=/etc/munin/munin-node.conf mode=644
      notify: restart munin-node

    - name: copy over site config for munin master to poll with
      template: src=ansible-demo.conf.jinja dest=/etc/munin/

    - name: replace munin.conf on master
      template: src=munin.conf.jinja dest=/etc/munin/munin.conf mode=0644
      when: munin_master



Two of these, you've seen before in the common role, but the second has a "when" clause added to it.  If you recall, the hosts file has some variables added to the groups, we are using the munin_master variable here.  Installing the master as well as munin-node on the master(master for monitoring, environment processing events, etc) server.

The third and fourth make use of a template, which are Jinja2 templates and you are able to perform any Jinja2 templating functions within this file.  Then it sig upnals for a restart of munin-node.  So any updates to that config file will restart munin-node on the managed servers.  That definition is defined in the handlers directory of that role.

Filename: roles/munin/templates/munin-node.conf.jinja

    :::mako
    log_level 4
    log_file /var/log/munin/munin-node.log
    pid_file /var/run/munin/munin-node.pid
    background 1
    setsid 1

    user root
    group root

    # global_timeout 900
 
    # timeout 60

    # Regexps for files to ignore
    ignore_file ~$
    #ignore_file [#~]$  # FIX doesn't work. '#' starts a comment
    ignore_file DEADJOE$
    ignore_file \.bak$
    ignore_file %$
    ignore_file \.dpkg-(tmp|new|old|dist)$
    ignore_file \.rpm(save|new)$
    ignore_file \.pod$

    #host_name localhost.localdomain

    allow {{ munin_master_ip }}

    # Which address to bind to; 
    host {{ ansible_eth0['ipv4']['address'] }}
    # host 127.0.0.1

    # And which port
    port 4949

This is a basic, standard munin-node config file, with two points in it to notice, {{ }} make something a variable to be substituted in via jinja templates, and those variables are provided by ansible.  You can see my use of the munin_master_ip variable, as well as an ansible provided way to link directly to the managed hosts ip address on eth0 which I'm binding munin-node to listen on.  

This is all good stuff, but again, really pretty basic.  One of the coolest parts of Ansible, and what made me start using it is what comes next for this little setup.  Auto configuration on the master.  Allowing the temp-master server to know about IP addresses of the servers in the other groups.  Very cool stuff here we go with that config file, but since it is a pretty long file I'm just going to show the most interesting bits of the file here, look at the source for the full file.

Filename: roles/munin/templates/munin.conf.jinja

    :::mako
    ...

    # a simple host tree
    [temp-master]
      address {{ ansible_eth0['ipv4']['address'] }}
      use_node_name yes

    {% for host in groups['webservers'] %}
    [WebServer;{{ hostvars[host].ansible_hostname }}]
      address {{ hostvars[host].ansible_eth0['ipv4']['address'] }}
      use_node_name yes

    {% endfor %}
    
    {% for host in groups['lbservers'] %}
    [LoadBalancer;{{ hostvars[host].ansible_hostname }}]
      address {{ hostvars[host].ansible_eth0['ipv4']['address'] }}
      use_node_name yes

    {% endfor %}


You'll see I'm able to loop through hostname and IP addresses for nodes defined in the hosts file based on their groups.  From the master server.  VERY Cool that its so simple to do.

Thats a great primer for Ansible and getting started into some of the cool features it has right out of the box.  Check back for another blog post showing some nginx webserver action.


