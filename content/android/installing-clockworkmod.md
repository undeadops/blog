Title: Installing ClockworkMod Recovery on G2x from Linux
Date: 2011-10-01 10:20
Modified: 2011-10-01 10:20
Category: Android
Tags: clockworkmod, android
Slug: installing-clockworkmod-recovery-on-g2x-from-linux
Authors: Mitch

I said I was going to write about my experiences with this... and never came back to it. I've been running custom ROM's since my first post about rooting my G2x. However, I honestly was a little unsure about the whole process so I didn't want to write about the other bits. I went back through and upgraded ClockWorkMod Recovery again, this time it was a little less unnerving so, I will write down my steps here.
First... I'm following bits from this [xda thread](http://forum.xda-developers.com/showthread.php?t=1056847 "XDA Thread")

I downloaded the rar file and pulled out the bits needed for ClockWorkMod (CWM) 5.0.2.0, so I could flash it from linux. I originally had a script that I used to flash this... my appologies I don't remember where, nor do I want to claim it as my own... I will include it however at the bottom of this post. Anyway, here goes. After grabbing the files above and the nvflash bin and a script, I put all of this in a CWM-5.0.2 directory

    mitch@kraven:~/g2xroot/CWM-5.0.2$ ls -l
    total 5008
    -rw-r--r-- 1 mitch mitch 3563520 2011-09-06 20:58 CWM-5020.img
    -rw-r--r-- 1 mitch mitch    4080 2011-04-21 00:40 E1108_Hynix_512MB_H8TBR00U0MLR-0DM_300MHz_final_emmc_x8.bct
    -rw-r--r-- 1 mitch mitch 1024992 2011-04-21 12:00 fastboot.bin
    -rwxr-xr-x 1 mitch mitch     125 2011-10-01 15:59 flash-recovery.sh
    -rwxr-xr-x 1 mitch mitch  526131 2011-10-01 15:58 nvflash

Before running the script, you need to connect your phone, follow these steps: 
- pull the battery on my phone 
- plug USB cable in laptop 
- Hold Volume Up AND Volume Down 
- *WHILE* holding #3, plug in USB to phone

This should result in a PCI connection to your phone... Your phone will not do anything.

    mitch@kraven:~/g2xroot/CWM-5.0.2$ lspci
    ....
    15:00.2 SD Host controller: Ricoh Co Ltd R5C822 SD/SDIO/MMC/MS/MSPro Host Adapter (rev 21)
    15:00.4 System peripheral: Ricoh Co Ltd R5C592 Memory Stick Bus Host Adapter (rev 11)
    15:00.5 System peripheral: Ricoh Co Ltd xD-Picture Card Controller (rev 11)

From there, you run the flash-recovery.sh script.

    mitch@kraven:~/g2xroot/CWM-5.0.2$ ./flash-recovery.sh 
    Nvflash started
    rcm version 0X20001
    System Information:
       chip name: unknown
       chip id: 0x20 major: 1 minor: 3
       chip sku: 0xf
       chip uid: 0x02884207417fe4d7
       macrovision: disabled
       hdcp: enabled
       sbk burned: false
       dk burned: false
       boot device: emmc
       operating mode: 3
       device config strap: 0
       device config fuse: 17
       sdram config strap: 0
    
     
    downloading bootloader -- load address: 0x108000 entry point: 0x108000
    sending file: fastboot.bin
    / 1024992/1024992 bytes sent
    fastboot.bin sent successfully
    waiting for bootloader to initialize
    bootloader downloaded successfully
    sending file: CWM-5020.img
    | 3563520/3563520 bytes sent
    CWM-5020.img sent successfully

At this point... you phone will be showing a "software upgrade is in progress" screen...
even after it completes... the above output took around 15 seconds to play out... and they say you can
unplug right after this.. I left it pluged in for another 30 seconds... cause it makes me nervous... (probably
unfounded...)
Download files [here](http://metauser.net/files/ClockWorkMod-5.0.2-Linux.tar.gz "ClockWorkMod-5.0.2-Linux.tar.gz")

