#!/bin/sh
#
#
#  Manual steps:
# 
# 1) Flash a lite Debian image to card via Win32DiskImager (e.g., 2017-11-29-raspbian-stretch-lite.zip)
# 
# 2) Create an empty text file  called "SSH" in the root of the SD card.
# 
# 3) Insert SD card into RPi and turn on.
#
# 4) Connect to RPi on port 22 (login: pi/raspberry) (e.g., Putty) 
#    Check your router or use a network sniffer like Fing (Android) to locate the RPi's IP address
#
# 5) Expand file system
#      sudo raspi-config
#      7 Advanced Options
#      A1 Expand Filesystem
#      restart RPi
#
# 6) Run this script to finish setup
#
# 7) After script completes, you can restore an existing HG configuration 
#
#
# Basic RPi coniguration (adjust localization as appropriate)
sudo raspi-config nonint do_hostname RPi3
sudo raspi-config nonint do_wifi_country US
sudo raspi-config nonint do_change_locale en_US.UTF-8 UTF-8
sudo raspi-config nonint do_change_timezone America/Los_Angeles
# 
# Install needed utilities and update system
yes | sudo apt-get install gdebi-core
yes | sudo apt-get update
yes | sudo apt-get upgrade
#
# Install Mono
# 5.4
#yes | sudo apt-get install dirmngr
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
#echo "deb http://download.mono-project.com/repo/debian stable-raspbianstretch/snapshots/5.4.0 main" | sudo tee /etc/apt/sources.list.d/mono-official.list
#sudo apt-get update
#yes | sudo apt-get install mono-complete
# 5.6
#yes | sudo apt-get install dirmngr
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
#echo "deb http://download.mono-project.com/repo/debian stable-raspbianstretch/snapshots/5.6.0 main" | sudo tee /etc/apt/sources.list.d/mono-official.list
#sudo apt-get update
#yes | sudo apt-get install mono-complete
# 4.6
yes | sudo apt-get install dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian stable-raspbianstretch/snapshots/4.6.0 main" | sudo tee /etc/apt/sources.list.d/mono-official.list
sudo apt-get update
yes | sudo apt-get install mono-complete
#
# Install SSL
yes | sudo apt-get install ca-certificates-mono
yes | sudo apt-get dist-upgrade
yes | sudo certmgr -ssl smtps://smtp.mail.yahoo.com:465
yes | sudo certmgr -ssl smtps://smtp.gmail.com:465
# to confirm setup:
# echo "" | openssl s_client -tls1 -showcerts -connect smtp.mail.yahoo.com:465
#
#
# Install MQTT software (Mosquitto)
# Guide: http://mosquitto.org/2013/01/mosquitto-debian-repository/
sudo apt-key add mosquitto-repo.gpg.key
pushd /etc/apt/sources.list.d/
sudo wget http://repo.mosquitto.org/debian/mosquitto-stretch.list
yes | sudo apt-get update
yes | sudo apt-get install mosquitto mosquitto-clients
popd
#
# Watch incoming MQTT messages:
# mosquitto_sub -t "#" -v
#   
# Publish MQTT:
# mosquitto_pub -t test/test -m test
#
#
# Install Samba
# http://raspberrywebserver.com/serveradmin/share-your-raspberry-pis-files-and-folders-across-a-network.html
yes | sudo apt-get install samba samba-common-bin
# Modify /etc/samba/smb.conf to correct configuration
sudo sed -i 's/#   wins support = no/   wins support = yes/g' /etc/samba/smb.conf
sudo sed -i '$ a [piroot]\n   comment= Pi root\n   path=/\n   browseable=Yes\n   writeable=Yes\n   only guest=no\n   create mask=0777\n   directory mask=0777\n   public=no' /etc/samba/smb.conf
#user/password = pi/pi  change if security is important to you!
#echo -ne "pi\npi\n" | sudo smbpasswd -a -s pi
# 
#
# Install RPI-clone
yes | sudo apt-get install git
git clone https://github.com/billw2/rpi-clone.git 
sudo cp rpi-clone/rpi-clone /usr/local/sbin
#
# To backup to usb flash drive (or sd card in usb adapter) at sda:
# sudo rpi-clone -v -f sda
#
# To add crontab event
# 0 2 * * * sudo rpi-clone -q -f sda
#
#
# Install HG 
# https://github.com/genielabs/HomeGenie/releases
# 1.1.15
#wget https://github.com/Bounz/HomeGenie-BE/releases/download/V1.1.15/homegenie_1.1.15_all.deb
#yes | sudo gdebi homegenie_1.1.15_all.deb
#
# 1.1.525
#sudo wget https://github.com/genielabs/HomeGenie/releases/download/v1.1-beta.525/homegenie-beta_1.1.r525_all.deb
#yes | sudo gdebi homegenie-beta_1.1.r525_all.deb
#
# 1.1.526
#sudo wget https://github.com/genielabs/HomeGenie/releases/download/v1.1-beta.526/homegenie-beta_1.1.r526_all.deb
#yes | sudo gdebi homegenie-beta_1.1.r526_all.deb
#
# 1.1.527
sudo wget https://github.com/genielabs/HomeGenie/releases/download/v1.1-stable.527/homegenie_1.1-stable.527_all.deb
yes | sudo gdebi homegenie_1.1-stable.527_all.deb
#
# 1.2.26
#sudo wget https://github.com/genielabs/HomeGenie/releases/download/v1.2-stable.26/homegenie_1.2-stable.26_all.deb
#yes | sudo gdebi homegenie_1.2-stable.26_all.deb
#
# Alternate use of tgz files
#
# 1.1.525
#wget https://github.com/genielabs/HomeGenie/releases/download/v1.1-beta.525/homegenie_1_1_beta_r525.tgz
#tar -xvzf homegenie_1_1_beta_r525.tgz
#sudo mv homegenie /usr/local/bin/.
#
# 1.1.526
#wget https://github.com/genielabs/HomeGenie/releases/download/v1.1-beta.526/homegenie_1_1_beta_r526.tgz
#tar -xvzf homegenie_1_1_beta_r526.tgz
#sudo mv homegenie /usr/local/bin/.
#
# 1.1.15
#mkdir homegenie
#cd homegenie
#wget https://github.com/Bounz/HomeGenie-BE/releases/download/V1.1.15/homegenie_1.1.15_all.tgz
#mv homegenie_1.1.15_all.tgz homegenie_1.1.15_all.tar
#tar xavf homegenie_1.1.15_all.tar
#sudo mv homegenie /usr/local/bin/.
#cd ..
#
# uninstall homegenie if there is an issue
#sudo dpkg --remove homegenie

# Todo
#    sudo apt-get install apcupsd --assume-yes
#    sudo nano /etc/apcupsd/apcupsd.conf
#      UPSNAME UPS1
#      UPSCABLE usb
#      UPSTYPE usb
#      DEVICE
#    sudo nano /etc/default/apcupsd
#      ISCONFIGURED=yes
#    sudo service apcupsd restart
#
#	
#10) map log directory to file server
#    sudo mkdir /mnt/log
#    sudo mount -t cifs -o guest //RAID-STATION/Array1/Misc/HomeAutomation/HomeGenie/log /mnt/log
#    
#  *** NOT WORKING ***
#    sudo nano /etc/fstab
#    //RAID-STATION/Array1/Misc/HomeAutomation/HomeGenie/log /usr/local/bin/homegenie/log cifs guest 0 0
#    
#    broken:
#    //RAID-STATION/Array1/Misc/HomeAutomation/HomeGenie/log /usr/local/bin/homegenie/log cifs guest 0 0
#    
#    working on older installation:
#    \\RAID-STATION\Array1\Misc\HomeAutomation\HomeGenie\log /usr/local/bin/homegenie/log cifs
#
#    currently requires the following to work:
#    sudo mount -a
#  *** NOT WORKING ***
#
