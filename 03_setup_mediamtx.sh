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

###############################################
# Global settings -> WebRTC server

# Enable publishing and reading streams with the WebRTC protocol.
webrtc: yes
# Address of the WebRTC HTTP listener.
webrtcAddress: :8889
# Enable TLS/HTTPS on the WebRTC server.
webrtcEncryption: no
# Path to the server key.
# This can be generated with:
# openssl genrsa -out server.key 2048
# openssl req -new -x509 -sha256 -key server.key -out server.crt -days 3650
webrtcServerKey: server.key
# Path to the server certificate.
webrtcServerCert: server.crt
# List of allowed CORS origins.
# Supports wildcards: ['http://*.example.com']
webrtcAllowOrigins: ['*']
# List of IPs or CIDRs of proxies placed before the WebRTC server.
# If the server receives a request from one of these entries, IP in logs
# will be taken from the X-Forwarded-For header.
webrtcTrustedProxies: []
# Address of a local UDP listener that will receive connections.
# Use a blank string to disable.
webrtcLocalUDPAddress: :8189
# Address of a local TCP listener that will receive connections.
# This is disabled by default since TCP is less efficient than UDP and
# introduces a progressive delay when network is congested.
webrtcLocalTCPAddress: ''
# WebRTC clients need to know the IP of the server.
# Gather IPs from interfaces and send them to clients.
webrtcIPsFromInterfaces: yes
# List of interfaces whose IPs will be sent to clients.
# An empty value means to use all available interfaces.
webrtcIPsFromInterfacesList: []
# List of additional hosts or IPs to send to clients.
webrtcAdditionalHosts: []
# ICE servers. Needed only when local listeners can't be reached by clients.
# STUN servers allows to obtain and share the public IP of the server.
# TURN/TURNS servers forces all traffic through them.
webrtcICEServers2: []
  # - url: stun:stun.l.google.com:19302
  # if user is "AUTH_SECRET", then authentication is secret based.
  # the secret must be inserted into the password field.
  # username: ''
  # password: ''
  # clientOnly: false
# Time to wait for the WebRTC handshake to complete.
webrtcHandshakeTimeout: 10s
# Maximum time to gather video tracks.
webrtcTrackGatherTimeout: 2s
# The maximum time to gather STUN candidates.
webrtcSTUNGatherTimeout: 5s

paths:
  # example:
  # my_camera:
  #   source: rtsp://my_camera
  cam1:
    source: rtsp://172.14.0.175/live
    sourceProtocol: tcp
    sourceOnDemand: no
  cam2:
    source: rtsp://172.14.0.206/live
    sourceProtocol: tcp
    sourceOnDemand: no
  # Settings under path "all_others" are applied to all paths that
  # do not match another entry.
  all_others:
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

