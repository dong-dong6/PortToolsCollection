# PortTrafficForwarding

`forward.sh` 是一个用于在内网和外网之间实现端口流量转发的 Bash 脚本。它可以帮助你将外网端口的流量转发到内网指定的 IP 和端口，支持添加、删除和列出转发规则。

## 功能介绍

- **添加转发规则**：将外网端口的流量转发到内网指定的 IP 和端口。
- **删除转发规则**：删除指定的转发规则。
- **列出转发规则**：显示当前所有的转发规则。

## 使用说明

### 依赖安装

脚本会自动检查并安装必要的依赖库，包括 `socat`、`lsof` 和 `netcat`。支持 `apt-get` 和 `yum` 包管理器。

### 脚本使用

1. 克隆仓库或下载脚本文件：
    ```bash
    git clone https://github.com/dong-dong6/PortTrafficForwarding.git
    cd PortTrafficForwarding
    ```

2. 运行脚本：
    ```bash
    chmod +x forward.sh
    ./forward.sh
    ```

3. 脚本运行后会显示操作菜单：
    ```
    请选择操作:
    1) 添加转发
    2) 删除转发
    3) 列出所有规则
    ```

### 添加转发规则

选择 `1` 并按照提示输入内网 IP、内网端口和外网端口。脚本会检查内网服务是否可达，以及外网端口是否被占用，然后添加转发规则。

### 删除转发规则

选择 `2`，脚本会显示当前所有的转发规则，输入要删除的规则序号，脚本会终止相应的转发规则进程。

### 列出转发规则

选择 `3`，脚本会显示当前所有的转发规则，格式为：
```
TCP-LISTEN 内网IP:内网端口->外网端口
```

## 一键脚本

如果你想要一键安装和运行该脚本，可以使用以下命令：

```bash
curl -O https://raw.githubusercontent.com/dong-dong6/PortTrafficForwarding/main/forward.sh
chmod +x forward.sh
./forward.sh
```

## 注意事项

- 运行脚本需要 `root` 权限，以便安装依赖和管理端口。
- 确保目标内网服务正在运行，并且指定的内网 IP 和端口是可达的。
- 在删除转发规则时，请仔细确认规则序号，以避免误操作。

## 联系方式

如果你在使用过程中有任何问题或建议，请在 [GitHub Issues](https://github.com/dong-dong6/PortTrafficForwarding/issues) 中提出。

---

希望这个 `README.md` 文件能帮助你快速了解和使用 `forward.sh` 脚本。感谢你的使用！
