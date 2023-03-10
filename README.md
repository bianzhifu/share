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
如果使用Nginx反代DashBoard请添加一下配置
location / {
    proxy_pass http://127.0.0.1:8008;
}
location /agent {
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_pass http://127.0.0.1:8008;
}
location /client {
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_pass http://127.0.0.1:8008;
}
```

### mtz-agent    
```
一键安装 https://mtz.com 为你的dashboard地址 ffffffff-ffff-ffff-ffff-ffffffffffff 为 servers.json的secret    
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/mtz-agent.sh) https://mtz.com ffffffff-ffff-ffff-ffff-ffffffffffff       
一键卸载   
bash <(curl -s https://raw.githubusercontent.com/bianzhifu/share/master/install.sh) mtz-agent uninstall   
```

