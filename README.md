# Arolu 客户版安装

本仓库仅提供安装入口、说明和许可。业务源码保存在私有仓库；客户安装包通过 GitHub Releases 发布。

## 安装

使用专用的 Ubuntu 24.04 x86_64 服务器，准备 sudo 权限和可访问的公网 IPv4，并长期放行 TCP 80、443。安装会配置 PostgreSQL、Nginx、HTTPS 证书及 Arolu 服务 

唯一安装命令：

```bash
curl -fsSL https://raw.githubusercontent.com/Delukang/arolu-install/main/install.sh | sudo bash
```

当前安装入口为 **v0.6.8 预览版**；原稳定版本保留在 Releases。旧客户端首次升级仍使用原安装命令：
 ```bash
curl -fsSL https://raw.githubusercontent.com/Delukang/arolu-install/main/install.sh | sudo bash
```

安装完成后，请在私有 SSH 终端安全保存登录资料。2FA 二维码为仅 root 可读的 PNG；安装输出提供私密下载说明，也可手动输入绑定密钥。

首次升级到 v0.6.0 前，请先按原流程结束旧卡片管理并删除旧卡，核清未决订单和恢复任务；安装器不会代为平仓或清理。旧资产映射不迁移，已结算记录保留，新版个人配对规则须重新配置。迁移后不能回退到不兼容的旧程序，也不能恢复旧数据库后继续交易。

升级后从 **设置与帮助 → 版本与更新** 查看版本、检查更新、选择稳定／预览渠道并确认升级。系统不会自动升级；异常及暂停卡片不会因升级自动恢复运行。稳定版不会因发布下一个版本自动晋升。

本次预览发布未开展新增账户、新交易和人工操作、带原单重启的真实账户验收，也未开展完整界面升级、公网证书、首显及长时间性能验收。技术回归和隔离安装验证不代表这些项目验收通过。更新内容和升级限制见 [v0.6.8 说明](https://github.com/Delukang/arolu-install/releases/tag/customer-2f102a7a18e5349d4c5500c3b705a17f74a621dc)。
