#!/bin/sh
#
#
#  Manual steps:
# 
# 1) Flash a lite Debian image to card via Win32DiskImager (e.g., 2019-09-26-raspbian-buster-lite.zip)
# 
# 2) Create an empty text file  called "SSH" in the root of the SD card.
# 
# 3) Insert SD card into RPi and turn on.
#
# 4) Connect to RPi on port 22 (login: pi/raspberry) (e.g., Putty) 
#    Check your router or use a network sniffer like Fing (Android) to locate the RPi's IP address
#
# 5) Expand file system
#      sudo raspi-config nonint do_expand_rootfs
#      sudo reboot
#
# 6) Run this script to finish setup
#
# 7) After script completes, you can restore an existing HG configuration 
#
#
# Basic RPi coniguration (adjust localization as appropriate)
sudo raspi-config nonint do_hostname RPi3
# Check /etc/hosts to confirm valid entry (sometimes this breaks)

#sudo raspi-config nonint do_wifi_country US
sudo raspi-config nonint do_change_locale en_US.UTF-8 UTF-8
sudo raspi-config nonint do_change_timezone America/Los_Angeles

#set minimum gpu memory
sudo raspi-config nonint do_memory_split 16

#disable wifi and bt
echo 'dtoverlay=disable-wifi' | sudo tee -a /boot/config.txt
echo 'dtoverlay=disable-bt' | sudo tee -a /boot/config.txt

#fix issue with video output.  Non issue but eliminates error in dmesg
sudo usermod -aG video pi

# 
# Update system
sudo apt -y update
sudo apt -y upgrade

#Update Mono
sudo apt -y install apt-transport-https dirmngr gnupg ca-certificates
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/debian stable-raspbianbuster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt -y update 
sudo apt -y upgrade
sudo apt -y update 

# Install HG
sudo apt -y install gdebi-core
wget https://github.com/genielabs/HomeGenie/releases/download/v1.3-stable.19/homegenie_1.3-stable.19_all.deb
yes | sudo gdebi homegenie_1.3-stable.19_all.deb

#wget https://github.com/genielabs/HomeGenie/releases/download/v1.3-beta.1/homegenie_1.3-beta.1_all.deb
#sudo gdebi homegenie_1.3-beta.1_all.deb

#wget https://github.com/genielabs/HomeGenie/releases/download/v1.3-stable.14/homegenie_1.3-stable.14_all.deb
#sudo gdebi homegenie_1.3-stable.14_all.deb

#wget https://github.com/genielabs/HomeGenie/releases/download/v1.2-stable.39/homegenie_1.2-stable.39_all.deb
#sudo gdebi homegenie_1.2-stable.39_all.deb

#wget https://github.com/genielabs/HomeGenie/releases/download/v1.1-beta.500/homegenie-beta_1.1.r500_all.deb
#sudo gdebi homegenie-beta_1.1.r500_all.deb

# Update system
sudo apt -y update
sudo apt -y upgrade










# Install MQTT software (Mosquitto)
# Guide: http://mosquitto.org/2013/01/mosquitto-debian-repository/
#sudo apt-key add mosquitto-repo.gpg.key
#pushd /etc/apt/sources.list.d/
#sudo wget http://repo.mosquitto.org/debian/mosquitto-buster.list
sudo apt -y update
sudo apt -y install mosquitto mosquitto-clients
sudo systemctl enable mosquitto.service
#
# Watch incoming MQTT messages:
# mosquitto_sub -t "#" -v
#   
# Publish MQTT:
# mosquitto_pub -t test/test -m test
#



# Install Samba
# http://raspberrywebserver.com/serveradmin/share-your-raspberry-pis-files-and-folders-across-a-network.html
sudo apt -y install samba samba-common-bin
# Modify /etc/samba/smb.conf to correct configuration
sudo sed -i 's/#   wins support = no/   wins support = yes/g' /etc/samba/smb.conf
sudo sed -i '$ a [piroot]\n   comment= Pi root\n   path=/\n   browseable=Yes\n   writeable=Yes\n   only guest=no\n   create mask=0777\n   directory mask=0777\n   public=no' /etc/samba/smb.conf
#user/password = pi/pi  change if security is important to you!
#echo -ne "pi\npi\n" | sudo smbpasswd -a -s pi
# 


# Install RPI-clone
sudo apt -y install git
sudo git clone https://github.com/billw2/rpi-clone.git 
sudo cp rpi-clone/rpi-clone /usr/local/sbin
#
# find usb drive location
# ls -l /dev/disk/by-uuid/
#
# To backup to usb flash drive (or sd card in usb adapter) at sda:
# sudo rpi-clone -v -f sda
#
# To add crontab event
# 0 2 * * * sudo rpi-clone -q -f sda
#
#


# Install rtl_433
sudo apt -y install libtool libusb-1.0.0-dev librtlsdr-dev rtl-sdr build-essential autoconf cmake pkg-config doxygen 
sudo git clone https://github.com/merbanan/rtl_433.git
cd rtl_433/
sudo mkdir build
cd build
sudo cmake ..
sudo make
sudo make install

#  example command.  Must be added to service
# rtl_433 -F json -M utc | mosquitto_pub -t home/rtl_433 -l -h 192.168.0.200

# If there are errors related to rules, try reconnecting the SDR




# Todo
#    sudo apt -y install apcupsd
#    sudo nano /etc/apcupsd/apcupsd.conf
#      UPSNAME UPS10
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