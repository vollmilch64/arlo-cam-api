#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

sudo mkdir -p /opt/mediamtx
cd /opt/mediamtx
sudo wget https://github.com/bluenviron/mediamtx/releases/download/v1.15.6/mediamtx_v1.15.6_linux_arm64.tar.gz
sudo tar xzf mediamtx_v1.15.6_linux_arm64.tar.gz
sudo chmod +x mediamtx
sudo rm mediamtx.yml

cat << EOF > /opt/mediamtx/mediamtx.yml
################################
# Core services
################################
rtsp: yes
rtspAddress: :8554

webrtc: yes
webrtcAddress: :8889

paths:
  cam1:
    # Wi-Fi camera stream
    source: rtsp://172.14.0.175/live
    sourceProtocol: tcp
    sourceOnDemand: no

  cam2:
    source: rtsp://172.14.0.206/live
    sourceProtocol: tcp
    sourceOnDemand: no
EOF

cat << EOF > /etc/systemd/system/mediamtxserver.service
[Unit]
Description=Mediamtx Camera Server
After=network.target

[Service]
Type=simple
User=secureadmin
WorkingDirectory=/opt/mediamtx
ExecStart=/opt/mediamtx/mediamtx mediamtx.yml
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mediamtxserver.service
sudo systemctl start mediamtxserver.service

