#!/usr/bin/env bash
# Arolu public bootstrap. Only a complete, fixed-key-verified installer executes.
set -eu
arolu_install() {
    if [ "$#" -ne 0 ]; then
        echo '安装自动识别公网 IPv4，不接受手动 IP 或其他参数。' >&2
        return 1
    fi
    if [ "$(id -u)" -ne 0 ]; then
        echo '请使用安装说明中的 sudo bash 命令。' >&2
        return 1
    fi
    for tool in python3 openssl; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "缺少必要命令：$tool；尚未安装 Arolu。" >&2
            return 1
        fi
    done
    python3 - <<'AROLU_BOOTSTRAP'
import base64
import hashlib
import os
from pathlib import Path
import subprocess
import tempfile
import urllib.request
import urllib.error
from urllib.parse import urlsplit

PUBLIC_KEY_B64 = 'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUNvd0JRWURLMlZ3QXlFQTEwVVo0bDkrM25veklzaEc4b2hqOHBpRVFxc3BKSTNxdzFHZ29yUjdFRk09Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQo='
RELEASE = 'eab97aaa4bec9e8a42e49d9479ac3c5f84fb0823'
INSTALLER_SHA256 = '182045ac6559915c574898a0be2cb5a9fd9d3221236e6bf2b9ba80a58e8d707d'
SOURCE = 'https://github.com/Delukang/arolu-install/releases/download/customer-'+RELEASE


def fetch(name, target, maximum):
    try:
        request=urllib.request.Request(SOURCE+'/'+name,headers={'User-Agent':'Arolu-Installer/2'})
        with urllib.request.urlopen(request,timeout=30) as reply:
            if urlsplit(reply.url).scheme!='https':raise ValueError('下载发生非HTTPS重定向')
            data=reply.read(maximum+1)
        if len(data)>maximum:raise ValueError('安装引导超过大小上限')
        target.write_bytes(data)
    except (urllib.error.URLError, TimeoutError, ConnectionError):
        raise RuntimeError('GitHub Releases 下载失败；尚未执行安装程序，请检查网络后重试。') from None

def main():
    try:
        os.umask(0o077)
        with tempfile.TemporaryDirectory(prefix='arolu-bootstrap-') as temp:
            root=Path(temp)
            key=root/'release-public.pem';key.write_bytes(base64.b64decode(PUBLIC_KEY_B64,validate=True))
            installer=root/'install.py';signature=root/'install.py.sig'
            fetch('install.py',installer,1024*1024)
            fetch('install.py.sig',signature,128)
            result=subprocess.run(['openssl','pkeyutl','-verify','-pubin','-inkey',str(key),'-rawin',
                '-in',str(installer),'-sigfile',str(signature)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
            if result.returncode:raise ValueError('安装引导验签失败，已停止；不会改装旧版本。')
            if hashlib.sha256(installer.read_bytes()).hexdigest()!=INSTALLER_SHA256:
                raise ValueError('安装引导版本或哈希不同，已停止；不会降级执行。')
            subprocess.run(['python3',str(installer)],check=True)
    except (ValueError,RuntimeError,OSError,subprocess.CalledProcessError) as exc:
        raise SystemExit('安装未完成：'+str(exc))

if __name__=='__main__':main()

AROLU_BOOTSTRAP
}
arolu_install "$@"
