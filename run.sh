docker run -d -p 8888:8080 -p 6010:6010 \
  -e VNC_PASSWORD=q1w2e3r4\
  -e SCREEN_WIDTH=1920 \
  -e SCREEN_HEIGHT=1080 \
  -e WORKSPACE_NUM=1 \
  --restart unless-stopped \
  --name x11vnc webvnc-x11-light
