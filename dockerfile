# 基于Alpine的精简远程桌面镜像
# Docker运行命令：
# docker build -t webvnc-x11-light .
# 
# 
# 自定义分辨率和密码：
# docker run -d -p 8888:8080 -p 6010:6010 \
#   -e VNC_PASSWORD=yourpassword \
#   -e SCREEN_WIDTH=1440 \
#   -e SCREEN_HEIGHT=720 \
#   --name x11vnc webvnc-x11-light
# 
# 浏览器访问：http://localhost:8888 (直接访问，无需vnc.html)
# X11客户端连接：DISPLAY=localhost:10, 密码: q1w2e3r4

FROM ubuntu:20.04


# 设置环境变量（可通过docker run -e 覆盖）
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:10 \
    VNC_PASSWORD=Fz1QUFnJU2NdoX44EkG7 \
    SCREEN_WIDTH=1440 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=24

# 更换apt源为清华镜像（可选，加速下载）
# 如果需要使用默认源，请注释掉下面这行
RUN sed -i 's@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

# 安装必要的包
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    xterm \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建用户
RUN useradd -m -s /bin/bash desktop

# 创建必要的目录
RUN mkdir -p /home/desktop/.fluxbox /var/log/supervisor

# 配置Fluxbox
RUN echo 'session.screen0.workspaces: 4' > /home/desktop/.fluxbox/init && \
    echo 'session.screen0.toolbar.visible: true' >> /home/desktop/.fluxbox/init && \
    echo 'session.screen0.toolbar.placement: TopCenter' >> /home/desktop/.fluxbox/init && \
    echo '[begin] (Fluxbox)' > /home/desktop/.fluxbox/menu && \
    echo '  [exec] (Terminal) {xterm}' >> /home/desktop/.fluxbox/menu && \
    echo '  [separator]' >> /home/desktop/.fluxbox/menu && \
    echo '  [restart] (Restart)' >> /home/desktop/.fluxbox/menu && \
    echo '  [exit] (Exit)' >> /home/desktop/.fluxbox/menu && \
    echo '[end]' >> /home/desktop/.fluxbox/menu

# 设置文件权限
RUN chown -R desktop:desktop /home/desktop

# 将默认缩放模式从 'off' 修改为 'scale' (自动缩放至窗口)
RUN sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'scale');/" /usr/share/novnc/app/ui.js

# 配置noVNC默认页面，让根路径直接访问桌面
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# 创建supervisor配置
RUN printf '[supervisord]\n\
nodaemon=true\n\
user=root\n\
logfile=/var/log/supervisor/supervisord.log\n\
pidfile=/var/run/supervisord.pid\n\
\n\
[program:xvfb]\n\
command=Xvfb :10 -screen 0 %%(ENV_SCREEN_WIDTH)sx%%(ENV_SCREEN_HEIGHT)sx%%(ENV_SCREEN_DEPTH)s -listen tcp -ac +extension GLX +extension RENDER -dpi 96 -nolisten unix\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/supervisor/xvfb.log\n\
stderr_logfile=/var/log/supervisor/xvfb.log\n\
\n\
[program:fluxbox]\n\
command=su - desktop -c "DISPLAY=:10 fluxbox"\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/supervisor/fluxbox.log\n\
stderr_logfile=/var/log/supervisor/fluxbox.log\n\
depends_on=xvfb\n\
\n\
[program:x11vnc]\n\
command=x11vnc -forever -shared -noipv6 -passwd %%(ENV_VNC_PASSWORD)s -display :10 -noxrecord -noxfixes -noxdamage -wait 5\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/supervisor/x11vnc.log\n\
stderr_logfile=/var/log/supervisor/x11vnc.log\n\
depends_on=xvfb\n\
\n\
[program:novnc]\n\
command=websockify --web /usr/share/novnc 8080 localhost:5900\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/supervisor/novnc.log\n\
stderr_logfile=/var/log/supervisor/novnc.log\n\
depends_on=x11vnc\n' > /etc/supervisor/conf.d/supervisord.conf

# 创建启动终端的脚本
RUN printf '#!/bin/bash\nsu - desktop -c "DISPLAY=:10 xterm &"\n' > /usr/local/bin/start-terminal

RUN chmod +x /usr/local/bin/start-terminal

# 暴露端口
EXPOSE 8080 6010

# 设置工作目录
WORKDIR /home/desktop

# 启动命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
