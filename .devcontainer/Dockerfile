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

# Download Godot 4.2.2
RUN wget -q https://github.com/godotengine/godot/releases/download/4.2.2-stable/Godot_v4.2.2-stable_linux.x86_64.zip -O /tmp/godot.zip \
    && unzip /tmp/godot.zip -d /home/vscode/ \
    && chmod +x /home/vscode/Godot_v4.2.2-stable_linux.x86_64 \
    && chown -R vscode:vscode /home/vscode \
    && rm /tmp/godot.zip

EXPOSE 6080 5900
