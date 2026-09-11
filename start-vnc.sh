#!/usr/bin/env bash
set -euo pipefail

VNC_PASS="vscode"
X_DISPLAY=:99
XAUTH_FILE="/tmp/xvfb.auth"
VNC_DIR="/tmp/vnc"

mkdir -p "$VNC_DIR" /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

pkill -f 'Xvfb :99|x11vnc -display :99|openbox|websockify --web /usr/share/novnc 6080' >/dev/null 2>&1 || true
rm -f /tmp/.X99-lock "$XAUTH_FILE" "$VNC_DIR/passwd" "$VNC_DIR/xvfb.log" "$VNC_DIR/openbox.log" "$VNC_DIR/x11vnc.log" "$VNC_DIR/novnc.log"

x11vnc -storepasswd "$VNC_PASS" "$VNC_DIR/passwd" >/dev/null 2>&1

Xvfb "$X_DISPLAY" -screen 0 1280x800x24 -auth "$XAUTH_FILE" -nolisten tcp >"$VNC_DIR/xvfb.log" 2>&1 &
Xvfb_pid=$!
echo "Xvfb PID: $Xvfb_pid"

for _ in $(seq 1 50); do
  if [ -f "$XAUTH_FILE" ]; then
    break
  fi
  sleep 0.1
done

if [ ! -f "$XAUTH_FILE" ]; then
  echo "X auth file was not created. Inspect $VNC_DIR/xvfb.log"
  tail -n 50 "$VNC_DIR/xvfb.log" || true
  exit 1
fi

DISPLAY="$X_DISPLAY" XAUTHORITY="$XAUTH_FILE" openbox >"$VNC_DIR/openbox.log" 2>&1 &
Openbox_pid=$!
echo "Openbox PID: $Openbox_pid"

sleep 2

nohup x11vnc -display "$X_DISPLAY" -auth "$XAUTH_FILE" -noxdamage -forever -shared -rfbauth "$VNC_DIR/passwd" -rfbport 5900 >"$VNC_DIR/x11vnc.log" 2>&1 &
X11vnc_pid=$!
echo "x11vnc PID: $X11vnc_pid"

nohup websockify --web /usr/share/novnc 6080 localhost:5900 >"$VNC_DIR/novnc.log" 2>&1 &
Novnc_pid=$!
echo "noVNC PID: $Novnc_pid"

echo ""
echo "VNC is running."
echo "  Password: $VNC_PASS"
echo "  Direct VNC: localhost:5900"
echo "  Browser: http://localhost:6080/vnc.html"
