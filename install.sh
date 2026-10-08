#!/usr/bin/env bash
# Arolu public bootstrap. Only a complete, fixed-key-verified installer executes.
set -eu
arolu_install() {
    local scope=full
    if [ "$#" -eq 2 ] && [ "$1" = '--scope' ]; then
        case "$2" in
            full|web) scope="$2" ;;
            *) echo '安装范围只接受 --scope full 或 --scope web。' >&2; return 1 ;;
        esac
    elif [ "$#" -ne 0 ]; then
        echo '安装自动识别公网 IPv4，仅接受可选参数 --scope full|web。' >&2
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
    python3 - "$scope" <<'AROLU_BOOTSTRAP'
import base64
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import urllib.request
import urllib.error
from urllib.parse import urlsplit

PUBLIC_KEY_B64 = 'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUNvd0JRWURLMlZ3QXlFQTEwVVo0bDkrM25veklzaEc4b2hqOHBpRVFxc3BKSTNxdzFHZ29yUjdFRk09Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQo='
RELEASE = 'c8d50d162b63e26351314a4e05a06fdbbc0bee7f'
INSTALLER_SHA256 = '412cf48d3eacd8ed2c9ae385d791e92c2d96406d1e5d21053bf589a8fe62727f'
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

def main(scope='full'):
    try:
        if scope not in ('full','web'):raise ValueError('安装范围只接受 full 或 web。')
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
            subprocess.run(['python3',str(installer),'--scope',scope],check=True)
    except (ValueError,RuntimeError,OSError,subprocess.CalledProcessError) as exc:
        raise SystemExit('安装未完成：'+str(exc))

if __name__=='__main__':
    if len(sys.argv)!=2:raise SystemExit('安装范围参数无效。')
    main(sys.argv[1])

AROLU_BOOTSTRAP
}
arolu_install "$@"
