#!/bin/bash
SSID=YourSSID
WPA_PSK=YourStrongPassword
COUNTRY_CODE=CH
WLAN_IFACE=wlan0
CHANNEL=11

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# setup wifi access point
sudo nmcli con add type wifi ifname $WLAN_IFACE con-name nm-ap ssid $SSID
sudo nmcli con modify nm-ap 802-11-wireless.mode ap
sudo nmcli con modify nm-ap 802-11-wireless.band bg
sudo nmcli con modify nm-ap 802-11-wireless.channel $CHANNEL
sudo nmcli con modify nm-ap wifi-sec.key-mgmt wpa-psk wifi-sec.psk $WPA_PSK
sudo nmcli con modify nm-ap ipv4.method shared ipv4.addresses 172.14.0.1/24 ipv6.method ignore
sudo nmcli con up nm-ap
sudo systemctl enable NetworkManager
sudo nmcli con modify nm-ap connection.autoconnect-priority 10
sudo nmcli con modify nm-ap connection.interface-name wlan0
sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf <<EOF
[connection]
wifi.powersave = 2
EOF

useradd arlo -m -r -s /usr/sbin/nologin
cp -r ../arlo-cam-api/ /opt/arlo-cam-api
chown -R arlo:arlo /opt/arlo-cam-api
sudo -u arlo pip3 install -r /opt/arlo-cam-api/requirements.txt

echo "Now sudo reboot..."
