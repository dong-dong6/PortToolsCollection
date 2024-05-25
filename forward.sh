#!/bin/bash

# 读取用户输入的内网 IP 和端口
read -p "请输入内网 IP: " internal_ip
read -p "请输入内网端口: " internal_port

# 读取用户输入的外网端口
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

# 使用 socat 命令实现流量转发
socat TCP-LISTEN:${external_port},fork TCP:${internal_ip}:${internal_port} &

echo "流量转发已启动：从外网端口 ${external_port} 到内网 ${internal_ip}:${internal_port}"
