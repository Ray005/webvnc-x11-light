docker run -d -p 8888:8080 -p 6010:6010 \
  -e VNC_PASSWORD=q1w2e3r4\
  -e SCREEN_WIDTH=1440 \
  -e SCREEN_HEIGHT=720 \
  --restart unless-stopped \
  --name x11vnc webvnc-x11-light
