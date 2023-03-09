#!/bin/bash
os_arch=""

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
    elif [[ $(uname -m | grep 'i386\|i686') != "" ]]; then
        os_arch="386"
    elif [[ $(uname -m | grep 'aarch64\|armv8b\|armv8l') != "" ]]; then
        os_arch="arm64"
    elif [[ $(uname -m | grep 'arm') != "" ]]; then
        os_arch="arm"
    fi
}

install(){
  echo -e "> 安装"
  echo -e "正在版本号"
  local version=$(curl -m 10 -sL "https://api.github.com/repos/bianzhifu/share/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
  if [ ! -n "$version" ]; then
      echo -e "获取版本号失败，请检查本机能否链接 https://api.github.com/repos/bianzhifu/share/releases/latest"
      return 0
  else
      echo -e "当前最新版本为: ${version}"
  fi
  mkdir -p /opt/sfte
  chmod 777 /opt/sfte

  echo -e "正在下载"
  wget -O sfte_linux_${os_arch}.tar.gz https://github.com/bianzhifu/share/releases/download/${version}/sfte_linux_${os_arch}.tar.gz >/dev/null 2>&1
  if [[ $? != 0 ]]; then
      echo -e "${red}Release 下载失败，请检查本机能否连接 https://github.com/bianzhifu/share/releases/download/${version}/sfte_linux_${os_arch}.tar.gz"
      return 0
  fi
  tar xf sfte_linux_${os_arch}.tar.gz &&
      mv sfte /opt/sfte/sfte &&
      rm -rf sfte_linux_${os_arch}.tar.gz README.md

  echo -e "> 修改配置"

  cat > /etc/systemd/system/sfte.service <<- EOF
[Unit]
Description=SFTE
After=syslog.target
#After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/opt/sfte
ExecStart=/opt/sfte/sfte
Restart=always
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable sfte.service
  systemctl restart sfte.service
}

uninstall() {
    echo -e "> 卸载"
    systemctl disable sfte.service
    systemctl stop sfte.service
    rm -rf /etc/systemd/system/sfte.service
    systemctl daemon-reload
    rm -rf /opt/sfte/
}

show_usage() {
    echo "使用方法: "
    echo "--------------------------------------------------------"
    echo "./sfte.sh install                      - 安装"
    echo "./sfte.sh uninstall                    - 卸载"
    echo "--------------------------------------------------------"
}
pre_check
case $1 in
"install")
    install
    ;;
"uninstall")
    uninstall
    ;;
*) show_usage ;;
esac

