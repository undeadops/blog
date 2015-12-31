Title: Active Directory Authentication on Junos
Date: 2014-04-11 09:18
Category: Juniper
Tags: junos, Active Directory, authentication
Slug: ad-auth-junos
Authors: Mitch


You would first need to setup a Raidus Server, [here](http://docs.openvpn.net/how-to-tutorialsguides/administration/configuring-active-directory-windows-2008-server-r2-radius-server-for-openvpn-access-server/) are some instructions for initial setup from OpenVPN.  Below is the JUNOS changes (configured last on a 12.4 EX4200 Switch)

On the Junos box (test-sw01 in this case):

    set system login class tier1 permissions configure
    set system login class tier1 permissions interface
    set system login class tier1 permissions interface-control
    set system login class tier1 permissions system
    set system login class tier1 permissions view
    set system login class tier1 allow-configuration vlans
    set system login class tier2 permissions view-configuration
    set system login class tier3 permissions all
    set system login user tier1 class tier1
    set system login user tier2 class tier2
    set system login user tier3 class tier3
    set system authentication-order radius                 #auth 1st to radius server
    set system authentication-order password               #fails back to local auth if radius doesn't work
    set system radius-options password-protocol mschap-v2  #force encryption on auth
    set system syslog file radius authorization any        #log any auth requests into /var/log/radius file
    set system radius-server 192.168.1.25 secret supersecret  #Domain Controller (Server 2008)


For the sake of testing with non-production users, I created 3 test users in OU = Test OU.
User names, passwords, group membership:

- tier1-user-a, Front555, Network-Operations-Tier1 
- tier2-user-a, Front555, Network-Operations-Tier2  
- tier3-user-a, Front555, Network-Operations-Tier3  

Added them to their respective groups: OU = Resource Groups
Network-Operations-Tier1, 2, 3

On the Windows Server 2008, Server Manager Roles -> Network Policy... -> NPS (Local) -> RADIUS Client... -> RADIUS Clients

- Right-click, New RADIUS Client:
- Vendor name: RADIUS Standard
- Manual, <same password on the device: set system radius-server x.x.x.x secret ...>
- Checkboxes unchecked
 (One of these entries for each managed device on the network)

Within NPS (Local) -> Policies -> Connection Requests (one-time setup):

- Overview tab: Type of network access server: Unspecified
- Conditions: Client Vendor, RADIUS Standard

Within NPS (Local), Network Policies, Network Policies (one for each tier):

- Overview tab: Grant access; Type of network access server: Unspecified
- Conditions tab: Condition: User Groups: Corp\Network-Operations-Tier1 (or whatever group)
- Constraints tab: Auth Method: MS-CHAP-v2, User can change password
- Settings: 
  - Standard, Service-Type, Login
    - Attributes:
    - Vendor Specific, Vendor Code: 2636; Yes, it conforms; 
    - Config Attrib: attrib no.: tier1; format: String; value: tier1 (match to class name)

So for ongoing upkeep of the config, you'll need to add a new network policy for each new managed device, and put users in the respective AD group memberships.  
 
For troubleshooting purposes, log files on Radius/NPS are kept at: C:\Windows\system32\LogFiles.

On the EX switch, type:

    show log radius | last
    
That should be it.

