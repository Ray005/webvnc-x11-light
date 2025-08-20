# webvnc-x11-light dockerfile

* 已上传dockerhub

``` bash
docker pull hanyan009/webvnc-x11-light
```

* 运行

```bash
docker run -d -p 8888:8080 -p 6010:6010 \
  -e VNC_PASSWORD=q1w2e3r4\
  -e SCREEN_WIDTH=1440 \
  -e SCREEN_HEIGHT=720 \
  --restart unless-stopped \
  --name x11vnc webvnc-x11-light
```

* 构建

```bash
docker build -t webvnc-x11-light .
```

#使用

# 第一步：服务器运行web VNC docker

- 【注】要设置密码
    
    ```bash
    docker pull hanyan009/webvnc-x11-light
    docker run -d -p 8888:8080 -p 6010:6010 \
      -e VNC_PASSWORD=q1w2e3r4\
      -e SCREEN_WIDTH=1440 \
      -e SCREEN_HEIGHT=720 \
      --restart unless-stopped \
      --name x11vnc webvnc-x11-light
    
    ```
    
- 【解释】
    - `p 6010:6010`: 这是 x11接收端口，对应 DISPLAY 10。我们将用这个端口来接收X11转发。
    - `p 8888:8080`:  这是 **noVNC 网页服务的端口**。
    

# 第二步：**通过网页访问VNC桌面**

- 访问：http://<你的服务器IP>:8888

![image.png](attachment:baf95bf7-86ab-4740-a324-65a560dfcc5f:image.png)

# 第三步：在服务器端其他位置x11到vnc桌面

- 设置
    
    ```bash
    export DISPLAY=localhost:10 # 对应6010端口
    xclock # 测试
    ```
    
- 【注】为什么是6010对应 :10？
    
    
    | **系统/协议** | **显示名称 (Display Name)** | **端口计算公式** | **结果端口** | **主要用途** |
    | --- | --- | --- | --- | --- |
    | **标准 X11** | `:0` | `6000 + 0` | `6000` | 连接到物理显示器或原生虚拟X Server (Xvfb) |
    | **标准 X11** | `:1` | `6000 + 1` | `6001` | 连接到第二个X Server |
    | **VNC** | `:1` | `5900 + 1` | `5901` | VNC 客户端连接到 VNC 服务器的虚拟桌面 |

# Additional

## **创建别名简化操作**

- 如果你经常这样做，可以在宿主机的 `.bashrc` 或 `.zshrc` 中添加一个别名：然后就可以这样运行程序了：
    
    ```bash
    alias vnc-run='DISPLAY=localhost:1'
    vnc-run firefoxvnc-run xeyes
    ```