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

安装完成后，请在私有 SSH 终端安全保存登录资料。2FA 二维码为仅 root 可读的 PNG；安装输出提供私密下载说明，也可手动输入绑定密钥。升级保留密码、验证器、账户、账本及卡片模式，暂停卡片不会自动启动；运行卡片在限制解除、条件满足后按原参数交易。更新内容、二维码下载步骤和尚未验证的范围见 [Release 说明](https://github.com/Delukang/arolu-install/releases)。
