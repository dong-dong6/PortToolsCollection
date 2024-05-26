# README.md

## 简介

本项目提供了两个脚本，一个用于 Linux 平台（使用 Bash），另一个用于 Windows 平台（使用 PowerShell）。这些脚本提供了一些常见的网络和系统管理功能，如检查本地和外网端口服务、端口流量转发和防火墙规则管理。

## 目录
- [功能介绍](#功能介绍)
- [Linux (Bash) 脚本](#linux-bash-脚本)
  - [安装依赖](#安装依赖)
  - [使用方法](#使用方法)
  - [注意事项](#注意事项)
- [Windows (PowerShell) 脚本](#windows-powershell-脚本)
  - [使用方法](#使用方法-1)
  - [注意事项](#注意事项-1)

## 功能介绍

1. **本地端口服务检查**: 检查本地 IP 和端口的服务情况。
2. **检查外网端口服务**: 检查外网 IP 和端口的服务情况。
3. **端口流量转发**: 实现内网与外网端口的流量转发。
4. **防火墙规则管理**: 添加、删除和列出防火墙规则。

## Linux (Bash) 脚本

### 安装依赖

运行脚本之前，请确保系统有相应的包管理器(apt-get或者yum)，脚本会自动检查以下依赖的安装情况
- socat
- lsof
- netcat (nc)
- ufw

### 使用方法
#### 一键脚本
```sh
  bash <(curl -fsSL https://raw.githubusercontent.com/dong-dong6/PortToolsCollection/main/forward.sh)
```
1. 克隆本仓库到本地：
   ```sh
   git clone https://github.com/dong-dong6/PortToolsCollection.git
   cd PortToolsCollection
   ```

2. 赋予脚本可执行权限：
   ```sh
   chmod +x forward.sh
   ```

3. 运行脚本：
   ```sh
   ./forward.sh
   ```

4. 按照屏幕提示选择操作，并输入相应信息。

### 注意事项

- 脚本需要以 root 权限运行，以便安装依赖和管理防火墙规则。
- 确保 `socat`, `lsof`, `nc` 和 `ufw` 可通过包管理器安装。如果使用的系统不支持这些包管理器，需手动安装相应工具。
- 在终止服务时，请谨慎操作，确保不会影响到重要的系统服务。

## Windows (PowerShell) 脚本

### 使用方法
#### 一键脚本
```sh
(iwr https://raw.githubusercontent.com/dong-dong6/PortToolsCollection/main/forward-windows.ps1).content |iex
```

1. 克隆本仓库到本地：
   ```powershell
   git clone https://github.com/dong-dong6/PortToolsCollection.git
   cd PortToolsCollection
   ```

2. 运行脚本：
   ```powershell
   ./forward-windows.ps1
   ```

3. 按照屏幕提示选择操作，并输入相应信息。

### 注意事项

- 运行 PowerShell 脚本需要管理员权限。
- 使用 `Get-NetTCPConnection` 和 `Test-NetConnection` 需要 Windows 10 或更高版本的 PowerShell。
- 在终止服务时，请确保不会影响到重要的系统服务。

## 示例

### Linux 脚本运行示例

```sh
  _____                        _____                _    _    _  _    _  _
 |  __ \                      |  __ \              | |  | |  | || |  (_)| |
 | |  | |  ___   _ __    __ _ | |__) |  ___   _ __ | |_ | |  | || |_  _ | |
 | |  | | / _ \ | '_ \  / _` ||  ___/  / _ \ | '__|| __|| |  | || __|| || |
 | |__| || (_) || | | || (_| || |     | (_) || |   | |_ | |__| || |_ | || |
 |_____/  \___/ |_| |_| \__, ||_|      \___/ |_|    \__| \____/  \__||_||_|
                         __/ |
                        |___/

请选择操作:
1) 本地端口服务检查
2) 检查外网端口服务
3) 端口流量转发
4) 管理防火墙规则
输入选项 (1/2/3/4):
```

### Windows 脚本运行示例

```powershell
  _____                        _____                _    _    _  _    _  _
 |  __ \                      |  __ \              | |  | |  | || |  (_)| |
 | |  | |  ___   _ __    __ _ | |__) |  ___   _ __ | |_ | |  | || |_  _ | |
 | |  | | / _ \ | '_ \  / _` ||  ___/  / _ \ | '__|| __|| |  | || __|| || |
 | |__| || (_) || | | || (_| || |     | (_) || |   | |_ | |__| || |_ | || |
 |_____/  \___/ |_| |_| \__, ||_|      \___/ |_|    \__| \____/  \__||_||_|
                         __/ |
                        |___/

请选择操作:
1) 本地端口服务检查
2) 检查外网端口服务
输入选项 (1/2):
```

通过这些脚本，用户可以轻松地管理和检查本地和外网端口服务，并进行端口流量转发和防火墙规则管理。希望这些工具能够帮助您更好地进行系统管理和网络维护。
