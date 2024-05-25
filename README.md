### 使用方法
一键脚本
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/dong-dong6/PortTrafficForwarding/main/forward.sh)
```

1. 保存脚本到文件，例如 `forward.sh`。
2. 给予脚本执行权限：
    ```sh
    chmod +x forward.sh
    ```
3. 运行脚本：
    ```sh
    ./forward.sh
    ```

### 脚本说明

- 在启动流量转发之前，脚本会使用 `nc`（Netcat）检查内网 IP 和端口是否可达。
- 如果目标内网服务不可达，脚本会提示用户检查服务状态并退出。
- 如果目标服务可达，脚本会继续检查外网端口是否被占用，并终止占用该端口的进程。
- 最后，使用 `socat` 命令启动流量转发。

这样可以确保在启动流量转发之前，内网服务是可达的，从而避免 `Connection refused` 错误。
