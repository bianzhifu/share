#!/bin/bash
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh) mtz-agent install
sed -i 's/ExecStart=\/opt\/mtz-agent\/mtz-agent/ExecStart=\/opt\/mtz-agent\/mtz-agent -s="$1" -p="$2"/g' /etc/systemd/system/mtz-agent.service
systemctl daemon-reload
systemctl restart mtz-agent.service
