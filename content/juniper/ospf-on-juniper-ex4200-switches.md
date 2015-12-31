Title: OSPF on Juniper EX4200 Switches
Date: 2010-08-01 18:38
Category: Juniper
Tags: junos, ospf
Slug: ospf-on-juniper-ex4200-switches
Authors: Mitch

At work, I had a situation arrive where I have two buildings connected together with Metro Optical Ethernet. There are two lines, one 100Mbit Ethernet line through [Utopia](http://utopianet.org/ "Utopia") and another 200Mbit Ethernet line through [Qwest](http://qwest.com/ "Qwest").
I initially had a simple /30 subnet static route accross each line, with preferences as to which line to use. However... since these lines have optical to ethernet devices on each end... the only way my simple static route would fail over was if those devices lost power and shut down the link between them and my switches. So something a little more redundant that would check the actual connectivity of the lines was needed.

Enter OSPF, I had decided on using OSPF to enable dynamic routing for these networks. I will past show the relavent bits of my code here for future reference.
From my hub switch (main switch... with default route connected)

    policy-options {
        policy-statement export_default_route_into_ospf {
            from term1
                from {
                    route-filter 0.0.0.0/0 exact;
                }
                then accept;
             }
             term term2 {
                then reject;
             }
        }
    }
    protocols {
        ospf {
            export export_default_route_into_ospf;
            area 0.0.0.0 {
                interface ge-0/0/1.0 {
                    metric 10;
                }
                interface ge-1/0/1.0 {
                   metric 20;
                }
        }
    }

From the spoke switch:

    protocols {
        ospf {
            area 0.0.0.0 {
                interface ge-0/0/1.0 { 
                    metric 10;
                }
                interface ge-1/0/1.0 {
                    metric 20;
                }
                interface vlan.101 {
                    passive;
                }
                interface vlan.102 {
                    passive;
                }
            }
        }
    }

For simplicity's sake, interface ge-0/0/1.0 is connected to the same interface on the other switch stack... But that should be the whole config... each vlan on the spoke side, needs to be added to the same ospf area to be advertised to the other side.
After adding this... i was able to remove my static routes and everything has worked fine since. I've even had problems with the line since then... it failed over with out much trouble. I didn't even get a call about it.

