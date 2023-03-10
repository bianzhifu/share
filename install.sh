#!/bin/bash
os_arch=""
service_name=""

pre_check() {
  # Check if the 'systemctl' command exists
  if ! command -v systemctl >/dev/null 2>&1; then
    echo "This system is not supported: 'systemctl' command not found."
    exit 1
  fi

  # Check if the script is run as root user
  if [[ $EUID -ne 0 ]]; then
    echo -e "${red}Error:${plain} This script must be run as root!\n"
    exit 1
  fi

  # Check the architecture of the operating system
  case $(uname -m) in
    *x86_64*) os_arch="amd64";;
    *aarch64*|*armv8b*|*armv8l*) os_arch="arm64";;
    *) echo "This script only supports amd64 and arm64 architectures."
       exit 1;;
  esac
}


download_and_install_service() {
  local service_name="$1"
  local os_arch="$2"
  local service_url="https://github.com/bianzhifu/share/releases/latest"
  local version

  echo "Getting the latest version of $service_name..."

  version=$(curl -sSLf -m 10 "$service_url" | grep -oE 'tag_name":.*?[^\\]",' | head -n 1 | cut -d'"' -f4)

  if [ -z "$version" ]; then
    echo "Failed to get the latest version. Please check if you can access $service_url"
    return 1
  fi

  echo "The latest version of $service_name is $version"
  echo "Downloading $service_name..."

  curl -sSLf "https://github.com/bianzhifu/share/releases/download/$version/${service_name}_linux_$os_arch.tar.gz" \
    -o "/tmp/${service_name}_linux_$os_arch.tar.gz"

  if [[ $? -ne 0 ]]; then
    echo "Download failed: https://github.com/bianzhifu/share/releases/download/$version/${service_name}_linux_$os_arch.tar.gz"
    return 1
  fi

  tar -xzf "/tmp/${service_name}_linux_$os_arch.tar.gz" -C "/opt/$service_name" --strip-components=1 "${service_name}/README.md"
  chmod +x "/opt/$service_name/$service_name"

  echo "$service_name installation complete"
}

install_service() {
  local service_name=$1
  local service_script="/etc/systemd/system/${service_name}.service"

  cat << EOF > "$service_script"
[Unit]
Description=$service_name
After=syslog.target

[Service]
LimitMEMLOCK=infinity
LimitNOFILE=65535
Type=simple
User=root
Group=root
WorkingDirectory=/opt/$service_name
ExecStart=/opt/$service_name/$service_name
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  echo "Starting $service_name service..."
  systemctl daemon-reload
  systemctl enable "$service_name.service"
  systemctl restart "$service_name.service"
}


install() {
  local url=$1
  echo "Installing ${service_name}..."

  # Create the installation directory and set the permissions
  mkdir -p /opt/${service_name}/
  chmod 775 /opt/${service_name}/

  # Download the service
  if [ -z "$url" ]; then
    download_and_install_service ${service_name} ${os_arch}
  else
    echo "Downloading ${service_name} from ${url}"
    curl -sSLf "$url" -o "/opt/${service_name}/${service_name}.tar.gz"
    if [[ $? != 0 ]]; then
      echo "${red}Download failed: $url"
      return 1
    fi

    # Check if downloaded file is a tar.gz
    if tar -tzf "/opt/${service_name}/${service_name}.tar.gz" >/dev/null 2>&1; then
      # Extract downloaded file
      tar -xzf "/opt/${service_name}/${service_name}.tar.gz" -C /opt/${service_name}/ --strip-components=1
    else
      echo "Downloaded file is not a tar.gz, skipping extraction."
      mv "/opt/${service_name}/${service_name}.tar.gz" "/opt/${service_name}/${service_name}"
    fi
  fi

  # Configure and start the service as a systemd service
  install_service ${service_name}

  echo "${service_name} installation complete."
}

uninstall() {
  echo "Uninstalling ${service_name}..."
  
  systemctl stop ${service_name}.service
  systemctl disable ${service_name}.service
  rm -f /etc/systemd/system/${service_name}.service
  systemctl daemon-reload

  rm -rf /opt/${service_name}

  echo "${service_name} has been successfully uninstalled."
}


show_usage() {
  echo "Usage: "
  echo "---------------------------------------"
  echo "./install.sh ${service_name} install           - install"
  echo "./install.sh ${service_name} uninstall         - uninstall"
  echo "---------------------------------------"
}
service_name=$1
pre_check
if [ "$#" -eq 3 ]; then
  url=$3
else
  url=""
fi
case $2 in
  install)   install $url ;;
  uninstall) uninstall ;;
  restart)   restart ;;
  *)         show_usage ;;
esac
