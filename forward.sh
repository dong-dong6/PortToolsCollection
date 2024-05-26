#!/bin/bash

# 检查并安装必要依赖库
install_dependencies() {
    if ! command -v socat &> /dev/null; then
        echo -e "\e[31m[socat 未安装，正在安装...]\e[0m"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y socat
        elif command -v yum &> /dev/null; then
            sudo yum install -y socat
        else
            echo -e "\e[31m[未能识别包管理器，请手动安装 socat。]\e[0m"
            exit 1
        fi
    fi

    if ! command -v lsof &> /dev/null; then
        echo -e "\e[31m[lsof 未安装，正在安装...]\e[0m"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y lsof
        elif command -v yum &> /dev/null; then
            sudo yum install -y lsof
        else
            echo -e "\e[31m[未能识别包管理器，请手动安装 lsof。]\e[0m"
            exit 1
        fi
    fi

    if ! command -v nc &> /dev/null; then
        echo -e "\e[31m[nc (netcat) 未安装，正在安装...]\e[0m"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y netcat
        elif command -v yum &> /dev/null; then
            sudo yum install -y nc
        else
            echo -e "\e[31m[未能识别包管理器，请手动安装 netcat。]\e[0m"
            exit 1
        fi
    fi

    if ! command -v ufw &> /dev/null; then
        echo -e "\e[31m[ufw 未安装，正在安装...]\e[0m"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y ufw
        elif command -v yum &> /dev/null; then
            sudo yum install -y ufw
        else
            echo -e "\e[31m[未能识别包管理器，请手动安装 ufw。]\e[0m"
            exit 1
        fi
    fi
}

# 检查并设置 net.ipv4.ip_forward
check_ip_forward() {
    ip_forward=$(sysctl -n net.ipv4.ip_forward)
    if [ "$ip_forward" -ne 1 ]; then
        echo -e "\e[31m[net.ipv4.ip_forward 未启用，端口转发需要启用此设置。]\e[0m"
        read -p "是否启用 net.ipv4.ip_forward? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
            sudo sysctl -w net.ipv4.ip_forward=1
            sudo bash -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'
            echo -e "\e[32m[net.ipv4.ip_forward 已启用。]\e[0m"
        else
            echo -e "\e[31m[未启用 net.ipv4.ip_forward，无法进行端口转发。]\e[0m"
            exit 1
        fi
    fi
}

# 打印 logo
print_logo() {
    echo -e "\e[32m"
    echo "  _____                        _____                _    _    _  _    _  _"
    echo " |  __ \                      |  __ \              | |  | |  | || |  (_)| |"
    echo " | |  | |  ___   _ __    __ _ | |__) |  ___   _ __ | |_ | |  | || |_  _ | |"
    echo " | |  | | / _ \ | '_ \  / _\` ||  ___/  / _ \ | '__|| __|| |  | || __|| || |"
    echo " | |__| || (_) || | | || (_| || |     | (_) || |   | |_ | |__| || |_ | || |"
    echo " |_____/  \___/ |_| |_| \__, ||_|      \___/ |_|    \__| \____/  \__||_||_|"
    echo "                         __/ |"
    echo "                        |___/"
    echo -e "\e[0m"
}

# 安装必要依赖库
install_dependencies

while true; do
    # 打印 logo
    print_logo

    # 显示菜单
    echo -e "\e[36m请选择操作:\e[0m"
    echo -e "\e[33m1) 本地端口服务检查\e[0m"
    echo -e "\e[33m2) 检查外网端口服务\e[0m"
    echo -e "\e[33m3) 端口流量转发\e[0m"
    echo -e "\e[33m4) 管理防火墙规则\e[0m"
    read -p "输入选项 (1/2/3/4): " option

    case $option in
        1)
            # 本地端口服务检查
            read -p "请输入本地 IP [默认127.0.0.1]: " local_ip
            local_ip=${local_ip:-127.0.0.1}
            read -p "请输入端口: " port

            # 检查本地端口服务
            echo -e "\e[36m检查本地端口服务...\e[0m"
            if [ "$local_ip" == "127.0.0.1" ]; then
                # 检查本地服务
                if lsof -i TCP:${port}; then
                    echo -e "\e[32m端口 ${port} 上的服务信息:\e[0m"
                    lsof -i TCP:${port}
                    echo -e "\e[36m请选择操作:\e[0m"
                    echo -e "\e[33m1) 结束服务\e[0m"
                    echo -e "\e[33m2) 返回不进行处理\e[0m"
                    read -p "输入选项 (1/2): " local_option

                    case $local_option in
                        1)
                            # 结束服务
                            echo -e "\e[31m正在结束服务...\e[0m"
                            fuser -k ${port}/tcp
                            echo -e "\e[32m服务已结束。\e[0m"
                            ;;
                        2)
                            # 返回不进行处理
                            echo -e "\e[32m未进行任何处理。\e[0m"
                            ;;
                        *)
                            echo -e "\e[31m无效选项，请选择 1 或 2。\e[0m"
                            ;;
                    esac
                else
                    echo -e "\e[31m未找到端口 ${port} 上的服务。\e[0m"
                fi
            else
                # 检查其他内网IP服务
                if nc -z ${local_ip} ${port}; then
                    echo -e "\e[32m${local_ip}:${port} 上有服务在运行。\e[0m"
                else
                    echo -e "\e[31m${local_ip}:${port} 上无服务。\e[0m"
                fi
            fi
            ;;

        2)
            # 检查外网端口服务
            read -p "请输入外网 IP: " external_ip
            read -p "请输入端口: " external_port

            # 检查外网端口服务
            echo -e "\e[36m检查外网端口服务...\e[0m"
            if nc -z ${external_ip} ${external_port}; then
                echo -e "\e[32m外网 ${external_ip}:${external_port} 有服务在运行。\e[0m"
            else
                echo -e "\e[31m外网 ${external_ip}:${external_port} 无服务。\e[0m"
            fi
            ;;

        3)
            # 端口流量转发子菜单
            echo -e "\e[36m请选择操作:\e[0m"
            echo -e "\e[33m1) 添加转发\e[0m"
            echo -e "\e[33m2) 删除转发\e[0m"
            echo -e "\e[33m3) 列出所有转发规则\e[0m"
            read -p "输入选项 (1/2/3): " sub_option

            case $sub_option in
                1)
                    # 添加转发
                    check_ip_forward

                    read -p "请输入内网 IP [默认127.0.0.1]: " internal_ip
                    internal_ip=${internal_ip:-127.0.0.1}
                    read -p "请输入内网端口: " internal_port
                    read -p "请输入外网端口: " external_port

                    # 检查目标内网服务是否可达
                    echo -e "\e[36m检查目标内网服务是否可达...\e[0m"
                    if ! nc -z ${internal_ip} ${internal_port}; then
                        echo -e "\e[31m无法连接到内网 ${internal_ip}:${internal_port}，请检查目标服务是否正在运行并监听该端口。\e[0m"
                        continue
                    fi

                    # 检查外网端口是否被占用
                    if lsof -i TCP:${external_port} | grep LISTEN; then
                        echo -e "\e[31m外网端口 ${external_port} 已被占用，正在终止占用该端口的进程...\e[0m"
                        # 杀掉占用该端口的进程
                        fuser -k ${external_port}/tcp
                    fi

                    # 检查是否已存在相同的转发规则
                    if ps aux | grep '[s]ocat' | grep -q "TCP-LISTEN:${external_port},fork TCP:${internal_ip}:${internal_port}"; then
                        echo -e "\e[31m相同的转发规则已经存在：从外网端口 ${external_port} 到内网 ${internal_ip}:${internal_port}\e[0m"
                    else
                        # 使用 socat 命令实现流量转发
                        socat TCP-LISTEN:${external_port},fork TCP:${internal_ip}:${internal_port} &
                        echo -e "\e[32m流量转发已启动：从外网端口 ${external_port} 到内网 ${internal_ip}:${internal_port}\e[0m"
                    fi
                    ;;

                2)
                    while true; do
                        # 删除转发
                        echo -e "\e[36m当前流量转发规则:\e[0m"
                        ps aux | grep '[s]ocat' | awk '{print NR-1, $0}'

                        read -p "请输入要删除的规则序号: " rule_number

                        # 获取要删除规则的进程ID
                        pid=$(ps aux | grep '[s]ocat' | awk -v num=$rule_number 'NR==num+1 {print $2}')

                        if [ -z "$pid" ]; then
                            echo -e "\e[31m无效的规则序号。请输入正确ID，或者按Ctrl+C退出。\e[0m"
                        else
                            echo -e "\e[31m正在终止进程 ID 为 ${pid} 的流量转发规则...\e[0m"
                            # 杀掉相应的 socat 进程
                            kill -9 ${pid}
                            echo -e "\e[32m已删除的流量转发规则。\e[0m"
                            break
                        fi
                    done
                    ;;

                3)
                    while true; do
                        # 列出所有规则
                        echo -e "\e[36m当前所有流量转发规则:\e[0m"
                        # 使用 ps 命令找出正在运行的 socat 进程，并解析转发规则信息
                        ps aux | grep '[s]ocat' | grep -o 'TCP-LISTEN:[0-9]*,[^ ]* TCP:[0-9.]*:[0-9]*' | awk -F '[:, ]+' '{print $1 " " $5 ":" $6 "->" $2}'
                        
                        read -p "按回车键返回菜单。" dummy
                        break
                    done
                    ;;

                *)
                    echo -e "\e[31m无效选项，请选择 1, 2 或 3。请输入正确ID，或者按Ctrl+C退出。\e[0m"
                    ;;
            esac
            ;;

        4)
            # 防火墙管理子菜单
            echo -e "\e[36m请选择操作:\e[0m"
            echo -e "\e[33m1) 列出当前防火墙规则\e[0m"
            echo -e "\e[33m2) 添加防火墙规则\e[0m"
            read -p "输入选项 (1/2): " fw_option

            case $fw_option in
                1)
                    # 列出当前防火墙规则
                    echo -e "\e[36m当前防火墙规则:\e[0m"
                    sudo ufw status verbose
                    ;;

                2)
                    # 添加防火墙规则
                    read -p "请输入端口号: " fw_port
                    read -p "请输入协议 (tcp/udp) [默认tcp]: " fw_protocol
                    fw_protocol=${fw_protocol:-tcp}
                    read -p "允许访问的IP段 [默认0.0.0.0/0]: " fw_ip
                    fw_ip=${fw_ip:-0.0.0.0/0}
                    read -p "请输入备注 [默认当前时间]: " fw_comment
                    fw_comment=${fw_comment:-$(date)}
                    
                    # 添加防火墙规则
                    echo -e "\e[36m添加防火墙规则: 端口 ${fw_port}, 协议 ${fw_protocol}, 允许IP段 ${fw_ip}, 备注 ${fw_comment}\e[0m"
                    sudo ufw allow from ${fw_ip} to any port ${fw_port} proto ${fw_protocol} comment "${fw_comment}"
                    sudo ufw reload
                    echo -e "\e[32m防火墙规则已添加。\e[0m"
                    ;;

                *)
                    echo -e "\e[31m无效选项，请选择 1 或 2。\e[0m"
                    ;;
            esac
            ;;

        *)
            echo -e "\e[31m无效选项，请选择 1, 2, 3 或 4。请输入正确ID，或者按Ctrl+C退出。\e[0m"
            ;;
    esac
done
