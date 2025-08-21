# WebVNC X11 Light - 轻量级Web VNC桌面环境

## 项目介绍

**WebVNC X11 Light** 是一个基于Docker的轻量级Web VNC解决方案，它提供了一个可通过Web浏览器访问的虚拟桌面环境。该项目特别适用于远程开发、测试GUI应用程序以及需要图形界面的服务器环境。

## 主要特性

- 🖥️ **Web访问**: 通过浏览器直接访问VNC桌面，无需安装VNC客户端
- 🔒 **密码保护**: 支持自定义VNC访问密码，确保安全性
- 📐 **可调分辨率**: 支持自定义屏幕分辨率，适应不同显示需求
- 🔄 **X11转发**: 支持X11应用程序转发到VNC桌面显示
- 🐳 **容器化部署**: 基于Docker，部署简单，环境隔离
- 💡 **轻量级设计**: 优化的镜像大小，快速启动

## 适用场景

- 远程服务器GUI应用程序展示
- 无头服务器的图形界面访问
- 开发环境的远程访问
- CI/CD流程中的GUI测试
- 多用户共享的图形化工作环境

## 快速开始

### Docker Hub 镜像

* 已上传dockerhub

``` bash
docker pull hanyan009/webvnc-x11-light
```

### 运行容器

```bash
docker run -d -p 8888:8080 -p 6010:6010 \
  -e VNC_PASSWORD=q1w2e3r4\
  -e SCREEN_WIDTH=1280 \
  -e SCREEN_HEIGHT=720 \
  -e WORKSPACE_NUM=1 \
  --restart unless-stopped \
  --name x11vnc webvnc-x11-light
```

### 本地构建

```bash
docker build -t webvnc-x11-light .
```

## 详细使用说明

### 第一步：服务器运行Web VNC Docker容器

- 【注】要设置密码
    
    ```bash
    docker pull hanyan009/webvnc-x11-light
    docker run -d -p 8888:8080 -p 6010:6010 \
      -e VNC_PASSWORD=q1w2e3r4\
      -e SCREEN_WIDTH=1280 \
      -e SCREEN_HEIGHT=720 \
      --restart unless-stopped \
      --name x11vnc webvnc-x11-light
    
    ```
    
- 【解释】
    - `p 6010:6010`: 这是 x11接收端口，对应 DISPLAY 10。我们将用这个端口来接收X11转发。
    - `p 8888:8080`:  这是 **noVNC 网页服务的端口**。
    

### 第二步：通过网页访问VNC桌面

- 访问：http://<你的服务器IP>:8888

### 第三步：在服务器端其他位置转发X11到VNC桌面

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

## 高级配置

### 创建别名简化操作

- 如果你经常这样做，可以在宿主机的 `.bashrc` 或 `.zshrc` 中添加一个别名：然后就可以这样运行程序了：
    
    ```bash
    alias vnc-run='DISPLAY=localhost:10'
    vnc-run firefox
    vnc-run xeyes
    ```

## 配置参数说明

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `VNC_PASSWORD` | 无 | VNC访问密码（强烈建议设置） |
| `SCREEN_WIDTH` | 1024 | 虚拟桌面宽度 |
| `SCREEN_HEIGHT` | 768 | 虚拟桌面高度 |

| 端口映射 | 说明 |
|---------|------|
| `8080:8080` | noVNC Web服务端口 |
| `6010:6010` | X11转发端口（对应DISPLAY :10） |

## 故障排除

### 常见问题

1. **无法连接Web VNC**
   - 检查防火墙设置，确保8888端口开放
   - 确认容器正在运行：`docker ps`

2. **X11应用无法显示**
   - 确认DISPLAY环境变量设置正确：`export DISPLAY=localhost:10`
   - 检查X11转发端口6010是否可访问

3. **密码无效**
   - 确认VNC_PASSWORD环境变量已正确设置
   - 重启容器使新密码生效

## 技术架构

该项目基于以下技术栈：
- **noVNC**: HTML5 VNC客户端，提供Web访问界面
- **X11VNC**: X11服务器，处理图形显示
- **Xvfb**: 虚拟帧缓冲区，提供无头显示环境
- **Docker**: 容器化部署平台
- **fluxbox**: 轻量级窗口化管理
