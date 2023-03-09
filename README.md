# share

### sfte   
```
liunx 安装
一键安装
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/sfte.sh) install
一键卸载
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/sfte.sh) uninstall

编译/etc/systemd/system/sfte.service进行个性化参数定制
例如
ExecStart=/opt/sfte/sfte -cpu=99 -mem=99 -upload=60```
