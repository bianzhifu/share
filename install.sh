#!/bin/bash
os_arch=""
service_name=""

pre_check() {
  command -v systemctl >/dev/null 2>&1
  if [[ $? != 0 ]]; then
    echo "不支持此系统：未找到 systemctl 命令"
    exit 1
  fi
  # check root
  [[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

  ## os_arch
  if [[ $(uname -m | grep 'x86_64') != "" ]]; then
    os_arch="amd64"
  elif [[ $(uname -m | grep 'aarch64\|armv8b\|armv8l') != "" ]]; then
    os_arch="arm64"
  else
    echo "只支持amd64/arm64"
    exit 1
  fi
}

install() {
  echo -e "安装${service_name}"

  echo -e "正在${service_name}版本号"
  local version=$(curl -m 10 -sL "https://api.github.com/repos/bianzhifu/share/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
  if [ ! -n "$version" ]; then
      echo -e "获取版本号失败，请检查本机能否链接 https://api.github.com/repos/bianzhifu/share/releases/latest"
      return 0
  else
      echo -e "当前最新版本为: ${version}"
  fi

  mkdir -p /opt/${service_name}}/
  chmod 775 /opt/${service_name}/

  echo -e "下载${service_name}"
  wget -O ${service_name}_linux_${os_arch}.tar.gz https://github.com/bianzhifu/share/releases/download/${version}/${service_name}_linux_${os_arch}.tar.gz >/dev/null 2>&1
  if [[ $? != 0 ]]; then
    echo -e "${red}下载失败,https://github.com/bianzhifu/share/releases/download/${version}/${service_name}_linux_${os_arch}.tar.gz"
    return 0
  fi
  tar xf ${service_name}_linux_${os_arch}.tar.gz &&
      mv ${service_name} /opt/${service_name}/${service_name} &&
      rm -rf ${service_name}_linux_${os_arch}.tar.gz README.md
  chmod +x /opt/${service_name}/${service_name}


  echo -e "修改配置"

  service_script=/etc/systemd/system/${service_name}.service

  cat >$service_script <<EOFSCRIPT
[Unit]
Description=${service_name}
After=syslog.target
#After=network.target

[Service]
LimitMEMLOCK=infinity
LimitNOFILE=65535
Type=simple
User=root
Group=root
WorkingDirectory=/opt/${service_name}/
ExecStart=/opt/${service_name}/${service_name}
Restart=always

[Install]
WantedBy=multi-user.target
EOFSCRIPT
  chmod +x $service_script

  echo -e "正在启动服务"
  systemctl daemon-reload
  systemctl enable ${service_name}.service
  systemctl restart ${service_name}.service
}

uninstall() {
  echo -e "卸载"
  while true
  do
      read -r -p '你是否备份好/opt/${service_name}/目录下的文件,确认继续请输入Y?' choice
      case "$choice" in
        n|N) break;;
        y|Y)
          systemctl disable ${service_name}.service
          systemctl stop ${service_name}.service
          rm -rf /etc/systemd/system/${service_name}.service
          systemctl daemon-reload
          rm -rf /opt/${service_name}/
          break
        ;;
        *) echo '输入错误';;
      esac
  done
}


show_usage() {
  echo "使用方法: "
  echo "---------------------------------------"
  echo "./install.sh install           - 安装"
  echo "./install.sh uninstall         - 卸载"
  echo "---------------------------------------"
}
service_name=$1
pre_check
case $2 in
"install")
  install
  ;;
"uninstall")
  uninstall
  ;;
"restart")
  restart
  ;;
*) show_usage ;;
esac
