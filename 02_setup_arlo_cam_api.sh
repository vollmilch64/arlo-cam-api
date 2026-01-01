#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cd arlo_cam_api
sudo apt install python3-pip
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
sudo cp -r ../arlo-cam-api/ /opt/arlo-cam-api
chown -R secureadmin:secureadmin /opt/arlo-cam-api

cat << EOF > /etc/systemd/system/cameraserver.service
[Unit]
Description=Python Camera Server (venv)
After=network.target

[Service]
Type=simple
User=secureadmin
WorkingDirectory=/opt/arlo-cam-api
ExecStart=/opt/arlo-cam-api/.venv/bin/python server.py
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cameraserver.service
sudo systemctl start cameraserver.service


