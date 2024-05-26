# README

## 介绍

此项目包含两个脚本，分别用于 Linux 和 Windows 系统。这些脚本提供了对网络端口服务的检查、端口流量转发和防火墙规则管理的功能。

## 功能

### Linux (Bash)

- **检查并安装必要依赖库**：自动检测并安装 `socat`、`lsof`、`nc` (netcat) 和 `ufw`。
- **本地端口服务检查**：检查指定 IP 和端口是否有服务在运行。
- **检查外网端口服务**：检查指定外网 IP 和端口是否有服务在运行。
- **端口流量转发**：通过 `socat` 实现端口流量转发。
- **管理防火墙规则**：使用 `ufw` 管理防火墙规则，包括添加和列出规则。

### Windows (PowerShell)

- **检查并安装必要依赖库**：自动检测并安装必要的网络工具。
- **本地端口服务检查**：检查指定 IP 和端口是否有服务在运行。
- **检查外网端口服务**：检查指定外网 IP 和端口是否有服务在运行。
- **端口流量转发**：通过网络工具实现端口流量转发。
- **管理防火墙规则**：管理防火墙规则，包括添加和列出规则。

## 使用方法

### Linux (Bash)

1. **克隆或下载此项目**
   ```bash
   git clone https://github.com/yourusername/yourrepository.git
   cd yourrepository
   ```

2. **运行脚本**
   ```bash
   chmod +x script.sh
   ./script.sh
   ```

3. **根据提示选择操作**

### Windows (PowerShell)

1. **克隆或下载此项目**
   ```powershell
   git clone https://github.com/yourusername/yourrepository.git
   cd yourrepository
   ```

2. **运行脚本**
   ```powershell
   .\script.ps1
   ```

3. **根据提示选择操作**

## 注意事项

### Linux (Bash)

- **权限问题**：某些操作需要管理员权限，请确保脚本以 `sudo` 权限运行。
- **依赖库**：脚本自动安装的依赖库 `socat`、`lsof`、`nc` (netcat) 和 `ufw` 是必要的，请确保安装成功。
- **网络环境**：脚本涉及网络操作，请确保运行环境下网络配置正确。

### Windows (PowerShell)

- **权限问题**：某些操作需要管理员权限，请确保 PowerShell 以管理员权限运行。
- **依赖库**：脚本可能需要额外的网络工具，请确保这些工具可用。
- **防火墙设置**：脚本涉及防火墙规则管理，请谨慎操作以避免网络安全问题。

## 贡献

欢迎贡献代码和提出问题！请通过 GitHub 提交 pull requests 和 issues。
