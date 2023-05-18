#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <serveradd> <serverp>"
    exit 1
fi

SERVERADD="$1"
SERVERP="$2"

curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh | bash -s mtz-agent install

sed -i "s@ExecStart=/opt/mtz-agent/mtz-agent@ExecStart=/opt/mtz-agent/mtz-agent -s=\"$SERVERADD\" -p=\"$SERVERP\"@g" /etc/systemd/system/mtz-agent.service

systemctl daemon-reload
systemctl restart mtz-agent.service
