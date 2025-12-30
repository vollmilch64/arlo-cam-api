# Arlo Cam API

This project forks [brianschrameck/arlo-cam-api](https://github.com/brianschrameck/arlo-cam-api) which simulates the Arlo Basestation to communicate with cameras. The project simulates an Arlo Basestation with a Raspberry Pi 5 running bookworm. It currently connects two Arlo Pro 5 cameras.

## Setup Raspberry Pi 5

I did the setup work on my MacBook Pro M1 running Tahoe 26.1 and I used a 128GB micro SD card (altough a smaller e.g. 32 GB would be ok either).

### Prepare SD card

1. download 2025-11-24-raspios-bookworm-arm64-lite.img.xz from here : https://www.raspberrypi.com/software/operating-systems/
1. download Raspberry Pi Imager from here : https://www.raspberrypi.com/software/ and install it on your Mac
1. start Imager
1. select 'Raspberry Pi 5'
1. select 'Use custom' and select the downloaded image '2025-11-24-raspios-bookworm-arm64-lite.img.xz'
1. select your SD card as storage device
1. write

### Boot raspberry Pi

Connect a display and keyboard to your Raspberry Pi

1. plug the SD card into the Raspberry Pi and switch it on
1. select keyboard layout, e.g. German (Switzerland)
1. username and password
1. loging with your username and password
1. sudo raspi-config
1. 1 System options : S4 Hostname : cameraserver1
1. 3 Interface options : I1 SSH yes
1. reboot

### Configure Raspberry Pi

The Raspberry Pi is now accessible via ssh over the LAN. 

1. connect via ssh : ssh username@cameraserver1
1. sudo raspi-config
1. 5 Localisation Options : L2 Timezone : Europe Zurich
1. 5 Localisation Options : L4 WLAN Country : CH Switzerland

### Checkout arlo-cam-api repository

To be able to checkout this repository on the Raspberry Pi, we need to install git

1. sudo apt install git
1. git clone https://github.com/vollmilch64/arlo-cam-api.git
1. cd arlo-cam-api

### Setup wifi access point

The Raspberry Pi needs to act as a wifi access point in an own networking range, e.g. 172.14.0.x/24. The bash script 01_setup_wifi_access_point.sh does this job, so run it as root

```
sudo ./01_setup_wifi_access_point.sh
```
The script asks for an SSID and a WPA_PSK, see [capture real base station WPA-PSK](https://github.com/brianschrameck/arlo-cam-api?tab=readme-ov-file#capture-real-base-station-wpa-psk) for a detailed description, how to get it.

After a reboot, check for cameras connected to your new 'basestation'. This can be done with

```
sudo cat /var/lib/NetworkManager/dnsmasq-wlan0.leases
```

In my setup the output looks as follows :

```
nnnnnnnnnn fc:9c:98:xx:xx:xx 172.14.0.175 VMC4060-DXXXX *
nnnnnnnnnn fc:9c:98:xx:xx:xx 172.14.0.206 VMC4060-DXXXX *
```

If you get nothing, try to reboot cameras by remove/readd battery and wait some minutes.

