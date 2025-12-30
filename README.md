# Arlo Cam API

This project forks [brianschrameck/arlo-cam-api](https://github.com/brianschrameck/arlo-cam-api) which simulates the Arlo Basestation to communicate with cameras. The project simulates an Arlo Basestation with a Raspberry Pi 5 running bookworm. It currently connects two Arlo Pro 5 cameras.

## Setup Raspberry Pi 5

I did the setup work on my MacBook Pro M1 running Tahoe 26.1 and I used a 128GB micro SD card (altough a smaller e.g. 32 GB would be ok either).

### Prepare SD card

1. download [Raspberry Pi OS Lite (Bookworm)](https://downloads.raspberrypi.com/raspios_oldstable_lite_arm64/images/raspios_oldstable_lite_arm64-2025-11-24/2025-11-24-raspios-bookworm-arm64-lite.img.xz)
1. download Raspberry Pi Imager from here : https://www.raspberrypi.com/software/ and install it on your Mac
1. start Imager
1. select 'Raspberry Pi 5'
1. select 'Use custom' and select the downloaded image '2025-11-24-raspios-bookworm-arm64-lite.img.xz'
1. select 'Apple SDXC Reader Media' as storage device
1. write

### Boot raspberry Pi

Connect a display and keyboard to your Raspberry Pi

1. plug the SD card into the Raspberry Pi and switch it on
1. select keyboard layout, e.g. German (Switzerland)
1. username=secureadmin and password
1. loging with secureadmin and password
1. sudo raspi-config
1. 1 System options : S4 Hostname : cameraserver1
1. 3 Interface options : I1 SSH yes
1. Finish -> reboot

### Configure Raspberry Pi

The Raspberry Pi is now accessible via ssh over the LAN. 

1. connect via ssh : ssh secureadmin@cameraserver1
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
cd arlo-cam-api
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

### Setup arlo-cam-api

The arlo-cam-api server is responsible to trigger the cameras to send an rtsp stream to the Raspberry Pi. The bash script
02_setup_arlo_cam_api.sh does set up the server.

```
cd arlo-cam-api
sudo ./02_setup_arlo_cam_api.sh
```
To check whether the server runs, one can check for the stream with 'ffprobe'. This tool is part of the 'ffmpeg' package.

```
sudo apt install ffmpeg
ffprobe rtsp://172.14.0.175/live
ffprobe rtsp://172.14.0.206/live
```

### Setup mediamtx proxy

We use mediamtx to provide the camera streams on the local network. The bash script 03_setup_mediamtx does this job.

```
sudo ./03_setup_mediamtx.sh
```

To check whether the mediamtx server runs correctly, open a browser anywhere in your local network with the following url :

```
http://cameraserver1:8889/cam1/
```
or

```
http://cameraserver1:8889/cam2/
```
