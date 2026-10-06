# Arolu 客户版安装

本仓库仅提供安装入口、说明和许可。业务源码保存在私有仓库；客户安装包通过 GitHub Releases 发布。

## 安装

使用专用的 Ubuntu 24.04 x86_64 服务器，准备 sudo 权限和可访问的公网 IPv4，并长期放行 TCP 80、443。安装会配置 PostgreSQL、Nginx、HTTPS 证书及 Arolu 服务 

唯一安装命令：

```bash
curl -fsSL https://raw.githubusercontent.com/Delukang/arolu-install/main/install.sh | sudo bash
```

 更新版本命令：
 ```bash
curl -fsSL https://raw.githubusercontent.com/Delukang/arolu-install/main/install.sh | sudo bash
```
