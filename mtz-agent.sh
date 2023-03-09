#!/bin/bash
serveradd=$1
serverp=$2
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh) mtz-agent install
sed -i 's/ExecStart=\/opt\/mtz-agent\/mtz-agent/ExecStart=\/opt\/mtz-agent\/mtz-agent -s="${serveradd}" -p="${serverp}"/g' /etc/systemd/system/mtz-agent.service
systemctl daemon-reload
systemctl restart mtz-agent.service
