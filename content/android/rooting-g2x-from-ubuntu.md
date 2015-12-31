Title: Rooting G2x from Ubuntu
Date: 2011-06-09 12:23
Modified: 2011-06-09 12:23
Category: Android
Tags: clockworkmod, rooting, android
Slug: rooting-my-g2x-from-ubuntu
Authors: Mitch

ince my only desktop is my work Lenovo ThinkPad running Ubuntu 11.04, and the bulk of the articles out there reference Windows... I did find a few articles articulating how to root the T-Mobile G2x, but I thought I'd do a full write up here over what exactly I did to root my G2x and will do a followup with flashing a CyanogenMod Nightly to it as well.
First, I downloaded the latest Android SDK from Google
I extracted the tarball and renamed it to androidsdk in my home directory:

    $ tar -zxvf Downloads/android-sdk_r11-linux_x86.tgz
    $ mv android-sdk-linux_x86 androidsdk

I then added the following to my .bashrc file and load it into your environment variables

    $ export PATH=${PATH}:$HOME/androidsdk/tools:$HOME/androidsdk/platform-tools
    $ source .bashrc

The directory, platform-tools, will not exist yet, and you will need to download the Android SDK Platform-tools. To do this, you will run the command 

    $ android

This will startup a GUI, click Available packages -> Android Repository -> Android SDK Platform-tools, revision 5 (Revision may be updated... this was the version when I did this)
Click Install Selected wait till finished and close.
Now, we need to update udev to setup the proper device permissions for when we connect our phone.

    $ sudo echo 'SUBSYSTEM=="usb", SYSFS{idVendor}=="1004", MODE="0666"' >> /etc/udev/rules.d/51-android.rules

the idVendor string is unique per manufacturer, there is a list of them on Android Development here, But I've used the LG one here, since they're the maker of the G2x.
Then you need to restart udev

    $ sudo service udev restart


Now... we're almost done. I first attempted to use the SuperOneClick root... which wasn't working for me. I then found a shell script that was a simple root to... thought I'd give it a go, and it worked easily, which can be downloaded on xda
I will note that... at this point, you should be able to connect your phone via USB, turn on USB Debug Mode. Settings -> Applications -> Development -> USB Debugging. Then run: adb devices. Should return this... or something similar at least... not sure what the hex number is... serial#?

    $ adb devices
    List of devices attached 
    02884207417fe4d7    device

After Downloading the G2xRootMacLinux_v0.5.zip and unzipping it.

    mitch@kraven:~$ mkdir g2xroot
    mitch@kraven:~$ cd g2xroot/
    mitch@kraven:~/g2xroot$ unzip ../Downloads/G2xRootMacLinux_v0.5.zip 
    Archive:  ../Downloads/G2xRootMacLinux_v0.5.zip
       creating: G2xRootMacLinux_v0.5/
       creating: G2xRootMacLinux_v0.5/files/
      inflating: G2xRootMacLinux_v0.5/files/adb_linux  
      inflating: G2xRootMacLinux_v0.5/files/adb_mac  
      inflating: G2xRootMacLinux_v0.5/files/busybox  
      inflating: G2xRootMacLinux_v0.5/files/psneuter  
      inflating: G2xRootMacLinux_v0.5/files/shared.sh  
      inflating: G2xRootMacLinux_v0.5/files/su  
      inflating: G2xRootMacLinux_v0.5/files/Superuser.apk  
      inflating: G2xRootMacLinux_v0.5/Readme.txt  
      inflating: G2xRootMacLinux_v0.5/root.command  
      inflating: G2xRootMacLinux_v0.5/unroot.command  
    mitch@kraven:~/g2xroot$ ls
     G2xRootMacLinux_v0.5
    mitch@kraven:~/g2xroot$ cd G2xRootMacLinux_v0.5/
    mitch@kraven:~/g2xroot/G2xRootMacLinux_v0.5$ ls
    files  Readme.txt  root.command  unroot.command
    mitch@kraven:~/g2xroot/G2xRootMacLinux_v0.5$ less Readme.txt 
    mitch@kraven:~/g2xroot/G2xRootMacLinux_v0.5$ ./root.command 

    Checking for connected device...
    Pushing temporary root exploint (psneuter) to device...
    1262 KB/s (585731 bytes in 0.453s)
    Running psneuter on device...
    property service neutered.
    killing adbd. (should restart in a second or two)
    Waiting for device...
    Remounting /system read/write...
    remount succeeded
    Pushing su to /system/bin/su...
    635 KB/s (26324 bytes in 0.040s)
    Pushing busybox to /system/bin/busybox...
    1253 KB/s (1062992 bytes in 0.827s)
    Installing Superuser.apk android application...
    1283 KB/s (196521 bytes in 0.149s)
    Removing psneuter from device...
    
    
    Rebooting device...

    Once device has rebooted you should be rooted.
    Press Enter when you're ready to quit:  
    mitch@kraven:~/g2xroot/G2xRootMacLinux_v0.5$

And that was it. Phone is rooted.
Many Thanks to jnichols959 for the scripts!
Next up CyanogenMod Nightly

