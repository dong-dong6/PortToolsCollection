# 检查并安装必要依赖库
function Install-Dependencies {
    $dependencies = @("netcat", "lsof")
    foreach ($dep in $dependencies) {
        if (-not (Get-Command $dep -ErrorAction SilentlyContinue)) {
            Write-Host "$dep 未安装，正在安装..."
            if ($dep -eq "netcat") {
                choco install nmap -y
            } elseif ($dep -eq "lsof") {
                choco install lsof -y
            }
        }
    }
}

# 打印 logo
function Print-Logo {
    Write-Host -ForegroundColor Green @"
  _____                        _____                _    _    _  _    _  _
 |  __ \                      |  __ \              | |  | |  | || |  (_)| |
 | |  | |  ___   _ __    __ _ | |__) |  ___   _ __ | |_ | |  | || |_  _ | |
 | |  | | / _ \ | '_ \  / _` ||  ___/  / _ \ | '__|| __|| |  | || __|| || |
 | |__| || (_) || | | || (_| || |     | (_) || |   | |_ | |__| || |_ | || |
 |_____/  \___/ |_| |_| \__, ||_|      \___/ |_|    \__| \____/  \__||_||_|
                         __/ |
                        |___/
"@
}

# 安装必要依赖库
Install-Dependencies

while ($true) {
    # 打印 logo
    Print-Logo

    # 显示菜单
    Write-Host "请选择操作:"
    Write-Host "1) 本地端口服务检查"
    Write-Host "2) 检查外网端口服务"
    Write-Host "3) 端口流量转发"
    Write-Host "4) 管理防火墙规则"
    $option = Read-Host "输入选项 (1/2/3/4)"

    switch ($option) {
        1 {
            # 本地端口服务检查
            $local_ip = Read-Host "请输入本地 IP"
            $port = Read-Host "请输入端口"

            # 检查本地端口服务
            Write-Host "检查本地端口服务..."
            if ($local_ip -eq "127.0.0.1") {
                # 检查本地服务
                $output = lsof -i TCP:${port}
                if ($output) {
                    Write-Host "端口 ${port} 上的服务信息:"
                    Write-Host $output
                    Write-Host "请选择操作:"
                    Write-Host "1) 结束服务"
                    Write-Host "2) 返回不进行处理"
                    $local_option = Read-Host "输入选项 (1/2)"

                    switch ($local_option) {
                        1 {
                            # 结束服务
                            Write-Host "正在结束服务..."
                            Stop-Process -Id (lsof -t -i TCP:${port})
                            Write-Host "服务已结束。"
                        }
                        2 {
                            # 返回不进行处理
                            Write-Host "未进行任何处理。"
                        }
                        Default {
                            Write-Host "无效选项，请选择 1 或 2。"
                        }
                    }
                } else {
                    Write-Host "未找到端口 ${port} 上的服务。"
                }
            } else {
                # 检查其他内网IP服务
                $output = Test-NetConnection -ComputerName $local_ip -Port $port
                if ($output.TcpTestSucceeded) {
                    Write-Host "${local_ip}:${port} 上有服务在运行。"
                } else {
                    Write-Host "${local_ip}:${port} 上无服务。"
                }
            }
        }
        2 {
            # 检查外网端口服务
            $external_ip = Read-Host "请输入外网 IP"
            $external_port = Read-Host "请输入端口"

            # 检查外网端口服务
            Write-Host "检查外网端口服务..."
            $output = Test-NetConnection -ComputerName $external_ip -Port $external_port
            if ($output.TcpTestSucceeded) {
                Write-Host "外网 ${external_ip}:${external_port} 有服务在运行。"
            } else {
                Write-Host "外网 ${external_ip}:${external_port} 无服务。"
            }
        }
        3 {
            # 端口流量转发子菜单
            Write-Host "请选择操作:"
            Write-Host "1) 添加转发"
            Write-Host "2) 删除转发"
            Write-Host "3) 列出所有转发规则"
            $sub_option = Read-Host "输入选项 (1/2/3)"

            switch ($sub_option) {
                1 {
                    # 添加转发
                    $internal_ip = Read-Host "请输入内网 IP"
                    $internal_port = Read-Host "请输入内网端口"
                    $external_port = Read-Host "请输入外网端口"

                    # 检查目标内网服务是否可达
                    Write-Host "检查目标内网服务是否可达..."
                    $output = Test-NetConnection -ComputerName $internal_ip -Port $internal_port
                    if (-not $output.TcpTestSucceeded) {
                        Write-Host "无法连接到内网 ${internal_ip}:${internal_port}，请检查目标服务是否正在运行并监听该端口。"
                        continue
                    }

                    # 检查外网端口是否被占用
                    $output = lsof -i TCP:${external_port}
                    if ($output) {
                        Write-Host "外网端口 ${external_port} 已被占用，正在终止占用该端口的进程..."
                        # 杀掉占用该端口的进程
                        Stop-Process -Id (lsof -t -i TCP:${external_port})
                    }

                    # 检查是否已存在相同的转发规则
                    if (Get-Process -Name socat -ErrorAction SilentlyContinue) {
                        Write-Host "相同的转发规则已经存在：从外网端口 ${external_port} 到内网 ${internal_ip}:${internal_port}"
                    } else {
                        # 使用 netsh 命令实现流量转发
                        netsh interface portproxy add v4tov4 listenport=$external_port listenaddress=0.0.0.0 connectport=$internal_port connectaddress=$internal_ip
                        Write-Host "流量转发已启动：从外网端口 ${external_port} 到内网 ${internal_ip}:${internal_port}"
                    }
                }
                2 {
                    # 删除转发
                    Write-Host "当前流量转发规则:"
                    netsh interface portproxy show v4tov4

                    $rule_number = Read-Host "请输入要删除的规则序号"
                    $rule = (netsh interface portproxy show v4tov4)[$rule_number]
                    if ($rule) {
                        $parts = $rule -split "\s+"
                        $external_port = $parts[1]
                        netsh interface portproxy delete v4tov4 listenport=$external_port listenaddress=0.0.0.0
                        Write-Host "已删除的流量转发规则。"
                    } else {
                        Write-Host "无效的规则序号。请输入正确ID，或者按Ctrl+C退出。"
                    }
                }
                3 {
                    # 列出所有规则
                    Write-Host "当前所有流量转发规则:"
                    netsh interface portproxy show v4tov4
                    Read-Host "按回车键返回菜单。"
                }
                Default {
                    Write-Host "无效选项，请选择 1, 2 或 3。"
                }
            }
        }
        4 {
            # 防火墙管理子菜单
            Write-Host "请选择操作:"
            Write-Host "1) 列出当前防火墙规则"
            Write-Host "2) 添加防火墙规则"
            $fw_option = Read-Host "输入选项 (1/2)"

            switch ($fw_option) {
                1 {
                    # 列出当前防火墙规则
                    Write-Host "当前防火墙规则:"
                    netsh advfirewall firewall show rule name=all
                }
                2 {
                    # 添加防火墙规则
                    $fw_port = Read-Host "请输入端口号"
                    $fw_protocol = Read-Host "请输入协议 (tcp/udp) [默认tcp]"
                    if (-not $fw_protocol) { $fw_protocol = "tcp" }
                    $fw_ip = Read-Host "允许访问的IP段 [默认0.0.0.0/0]"
                    if (-not $fw_ip) { $fw_ip = "0.0.0.0/0" }
                    $fw_comment = Read-Host "请输入备注 [默认当前时间]"
                    if (-not $fw_comment) { $fw_comment = Get-Date }

                    # 添加防火墙规则
                    Write-Host "添加防火墙规则: 端口 $fw_port, 协议 $fw_protocol, 允许IP段 $fw_ip, 备注 $fw_comment"
                    netsh advfirewall firewall add rule name="$fw_comment" protocol=$fw_protocol dir=in localport=$fw_port action=allow remoteip=$fw_ip
                    Write-Host "防火墙规则已添加。"
                }
                Default {
                    Write-Host "无效选项，请选择 1 或 2。"
                }
            }
        }
        Default {
            Write-Host "无效选项，请选择 1, 2, 3 或 4。"
        }
    }
}
