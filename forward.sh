#!/bin/bash

# 检查并安装必要依赖库
install_dependencies() {
    if ! command -v socat &> /dev/null; then
        echo "socat 未安装，正在安装..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y socat
        elif command -v yum &> /dev/null; then
            sudo yum install -y socat
        else
            echo "未能识别包管理器，请手动安装 socat。"
            exit 1
        fi
    fi

    if ! command -v lsof &> /dev/null; then
        echo "lsof 未安装，正在安装..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y lsof
        elif command -v yum &> /dev/null; then
            sudo yum install -y lsof
        else
            echo "未能识别包管理器，请手动安装 lsof。"
            exit 1
        fi
    fi

    if ! command -v nc &> /dev/null; then
        echo "nc (netcat) 未安装，正在安装..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y netcat
        elif command -v yum &> /dev/null; then
            sudo yum install -y nc
        else
            echo "未能识别包管理器，请手动安装 netcat。"
            exit 1
        fi
    fi
}

# 安装必要依赖库
install_dependencies

# 显示菜单
echo "请选择操作:"
echo "1) 添加转发"
echo "2) 删除转发"
echo "3) 列出所有规则"
read -p "输入选项 (1/2/3): " option

case $option in
    1)
        # 添加转发
        read -p "请输入内网 IP: " internal_ip
        read -p "请输入内网端口: " internal_port
        read -p "请输入外网端口: " external_port

        # 检查目标内网服务是否可达
        echo "检查目标内网服务是否可达..."
        if ! nc -z ${internal_ip} ${internal_port}; then
            echo "无法连接到内网 ${internal_ip}:${internal_port}，请检查目标服务是否正在运行并监听该端口。"
            exit 1
        fi

        # 检查外网端口是否被占用
        if lsof -i TCP:${external_port} | grep LISTEN; then
            echo "外网端口 ${external_port} 已被占用，正在终止占用该端口的进程..."
            # 杀掉占用该端口的进程
            fuser -k ${external_port}/tcp
        fi

        # 检查是否已存在相同的转发规则
        if ps aux | grep '[s]ocat' | grep -q "TCP-LISTEN:${external_port},fork TCP:${internal_ip}:${internal_port}"; then
            echo "相同的转发规则已经存在：从外网端口 ${external_port} 到内网 ${internal_ip}:${internal_port}"
        else
            # 使用 socat 命令实现流量转发
            socat TCP-LISTEN:${external_port},fork TCP:${internal_ip}:${internal_port} &
            echo "流量转发已启动：从外网端口 ${external_port} 到内网 ${internal_ip}:${internal_port}"
        fi
        ;;

    2)
        # 删除转发
        echo "当前流量转发规则:"
        ps aux | grep '[s]ocat' | awk '{print NR-1, $0}'

        read -p "请输入要删除的规则序号: " rule_number

        # 获取要删除规则的进程ID
        pid=$(ps aux | grep '[s]ocat' | awk -v num=$rule_number 'NR==num+1 {print $2}')

        if [ -z "$pid" ]; then
            echo "无效的规则序号。"
            exit 1
        fi

        echo "正在终止进程 ID 为 ${pid} 的流量转发规则..."
        # 杀掉相应的 socat 进程
        kill -9 ${pid}
        echo "已删除的流量转发规则。"
        ;;

    3)
        # 列出所有规则
        echo "当前所有流量转发规则:"
        # 使用 ps 命令找出正在运行的 socat 进程，并解析转发规则信息
        ps aux | grep '[s]ocat' | grep -o 'TCP-LISTEN:[0-9]*,[^ ]* TCP:[0-9.]*:[0-9]*' | awk -F '[:, ]+' '{print $1 " " $5 ":" $6 "->" $2}'
        ;;

    *)
        echo "无效选项，请选择 1, 2 或 3."
        ;;
esac

exit 0
