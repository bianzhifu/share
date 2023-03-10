# share

### sfte   
```
一键安装
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh) sfte install
一键卸载
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh) sfte uninstall

编译/etc/systemd/system/sfte.service进行个性化参数定制
例如
ExecStart=/opt/sfte/sfte -cpu=99 -mem=99 -upload=60   
```


### mtz-dashboard    
```
一键安装   
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh) mtz-dashboard install   
一键卸载   
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh) mtz-dashboard uninstall 
在/opt/mtz-dashboard/servers.json添加你的服务器格式如下
[
  {
    "id": 1,
    "name": "服务器名字",
    "secret": "ffffffff-ffff-ffff-ffff-ffffffffffff"
  }
]
编译/etc/systemd/system/mtz-dashboard.service进行个性化参数定制   
例如  
ExecStart=/opt/mtz-dashboard/mtz-dashboard -port=80 -password="admin"   
```

### mtz-agent    
```
一键安装 https://mtz.com 为你的dashboard地址 ffffffff-ffff-ffff-ffff-ffffffffffff 为 servers.json的secret    
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/mtz-agent.sh) https://mtz.com ffffffff-ffff-ffff-ffff-ffffffffffff       
一键卸载   
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh) mtz-agent uninstall   
```

