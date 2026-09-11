FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install all required packages in one go
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    wget \
    unzip \
    curl \
    git \
    xfce4 \
    xfce4-terminal \
    xfce4-goodies \
    tightvncserver \
    novnc \
    websockify \
    dbus-x11 \
    x11-xserver-utils \
    xfonts-base \
    xfonts-100dpi \
    xfonts-75dpi \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libglu1-mesa \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libasound2 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Setup VNC password
RUN mkdir -p /home/vscode/.vnc \
    && echo -e "godot123\ngodot123\nn" | vncpasswd \
    && echo '#!/bin/bash\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4' > /home/vscode/.vnc/xstartup \
    && chmod +x /home/vscode/.vnc/xstartup

# Download Godot 4.2.2
RUN wget -q https://github.com/godotengine/godot/releases/download/4.2.2-stable/Godot_v4.2.2-stable_linux.x86_64.zip -O /tmp/godot.zip \
    && unzip /tmp/godot.zip -d /home/vscode/ \
    && chmod +x /home/vscode/Godot_v4.2.2-stable_linux.x86_64 \
    && rm /tmp/godot.zip

# Create startup script
RUN echo '#!/bin/bash\n\
echo "Starting VNC server..."\n\
vncserver :1 -geometry 1280x720 -depth 24 -localhost no\n\
sleep 2\n\
echo "Starting noVNC..."\n\
websockify --web=/usr/share/novnc 8080 localhost:5901 &\n\
echo "✅ VNC is ready! Open port 8080 in browser"\n\
echo "🔑 Password: godot123"\n\
echo "🎮 Godot: /home/vscode/Godot_v4.2.2-stable_linux.x86_64"\n\
tail -f /dev/null' > /home/vscode/start-vnc.sh \
    && chmod +x /home/vscode/start-vnc.sh

EXPOSE 8080 5901

CMD ["/home/vscode/start-vnc.sh"]
