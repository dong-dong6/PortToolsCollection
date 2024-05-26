# 设置正确的编码格式
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

# 检查本地端口服务
function Check-Local-Port {
    param (
        [string]$local_ip = "127.0.0.1",
        [int]$port
    )

    Write-Host "检查本地端口服务..."
    if ($local_ip -eq "127.0.0.1") {
        # 检查本地服务
        $output = Get-NetTCPConnection -LocalPort $port -State Listen
        if ($output) {
            Write-Host "端口 ${port} 上的服务信息:"
            $output | Format-Table -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess -AutoSize
            Write-Host "请选择操作:"
            Write-Host "1) 结束服务"
            Write-Host "2) 返回不进行处理"
            $local_option = Read-Host "输入选项 (1/2)"

            switch ($local_option) {
                1 {
                    # 结束服务
                    Write-Host "正在结束服务..."
                    Stop-Process -Id $($output.OwningProcess)
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

# 检查外网端口服务
function Check-External-Port {
    param (
        [string]$external_ip,
        [int]$external_port
    )

    Write-Host "检查外网端口服务..."
    $output = Test-NetConnection -ComputerName $external_ip -Port $external_port
    if ($output.TcpTestSucceeded) {
        Write-Host "外网 ${external_ip}:${external_port} 有服务在运行。"
    } else {
        Write-Host "外网 ${external_ip}:${external_port} 无服务。"
    }
}

while ($true) {
    # 打印 logo
    Print-Logo

    # 显示菜单
    Write-Host "请选择操作:"
    Write-Host "1) 本地端口服务检查"
    Write-Host "2) 检查外网端口服务"
    $option = Read-Host "输入选项 (1/2)"

    switch ($option) {
        1 {
            $local_ip = Read-Host "请输入本地 IP [默认: 127.0.0.1]"
            if (-not $local_ip) { $local_ip = "127.0.0.1" }
            $port = Read-Host "请输入端口"
            Check-Local-Port -local_ip $local_ip -port $port
        }
        2 {
            $external_ip = Read-Host "请输入外网 IP"
            $external_port = Read-Host "请输入端口"
            Check-External-Port -external_ip $external_ip -external_port $external_port
        }
        Default {
            Write-Host "无效选项，请选择 1 或 2。"
        }
    }
}
