FROM node:22-bookworm

# 安装基础依赖
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# 安装 devspace 
RUN npm install -g @waishnav/devspace
WORKDIR /opt/devspace

# 下载并安装 CLOUDFLARE TUNNEL
RUN wget -q -O /root/cloudflared-linux-amd64.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && apt-get update \
    && apt-get install -y /root/cloudflared-linux-amd64.deb \
    && rm -rf /root/cloudflared-linux-amd64.deb /var/lib/apt/lists/*

RUN devspace init

# 声明环境变量（留空，等待运行时输入）
ENV TUNNEL_TOKEN=""

# 编写一个简单的启动脚本
RUN echo '#!/bin/bash\n\
# 后台运行 cloudflare tunnel，并读取 $TUNNEL_TOKEN 变量\n\
cloudflared tunnel --no-autoupdate run --token "$TUNNEL_TOKEN" &\n\
# 前台运行 devspace 服务\n\
exec devspace serve' > /entrypoint.sh && chmod +x /entrypoint.sh

# 容器启动时执行脚本
CMD ["/entrypoint.sh"]
