#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/09_ai_dev_tools.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[9/9] SKIP: AI and Developer tools already installed"
  exit 0
fi

bitacora "[9/9] Installing AI and Developer tools (Quarto, OpenCode, and Antigravity IDE configuration)"

# 1. Install/Verify FFmpeg
bitacora "[9/9] Checking and installing FFmpeg..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ffmpeg

# 2. Install yt-dlp
bitacora "[9/9] Installing yt-dlp from official GitHub releases..."
sudo wget -q "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp" -O /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
bitacora "[9/9] yt-dlp installed: $(/usr/local/bin/yt-dlp --version)"

# 3. Install Quarto CLI
bitacora "[9/9] Installing Quarto CLI..."
if ! command -v quarto &>/dev/null; then
  # Fetch latest version from GitHub releases
  LATEST_QUARTO=$(curl -s https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
  wget -q "https://github.com/quarto-dev/quarto-cli/releases/download/v${LATEST_QUARTO}/quarto-${LATEST_QUARTO}-linux-amd64.deb" -O /tmp/quarto.deb
  sudo apt-get install -y /tmp/quarto.deb
  rm /tmp/quarto.deb
  bitacora "[9/9] Quarto installed: $(quarto --version)"
else
  bitacora "[9/9] Quarto already installed: $(quarto --version)"
fi

# 4. Install OpenCode CLI
bitacora "[9/9] Installing OpenCode CLI..."
if ! command -v opencode &>/dev/null; then
  curl -fsSL https://opencode.ai/install | bash
else
  bitacora "[9/9] OpenCode CLI already installed"
fi

# 5. Install OpenCode Desktop (Beta)
bitacora "[9/9] Installing OpenCode Desktop..."
LOCAL_DEB="/home/augusto/Downloads/Programs/opencode-desktop-linux-amd64.deb"
if [ -f "${LOCAL_DEB}" ]; then
  bitacora "[9/9] Installing OpenCode Desktop from local package..."
  sudo apt-get install -y "${LOCAL_DEB}"
else
  bitacora "[9/9] Downloading and installing OpenCode Desktop..."
  wget -q "https://opencode.ai/download/stable/linux-x64-deb" -O /tmp/opencode-desktop.deb
  sudo apt-get install -y /tmp/opencode-desktop.deb
  rm /tmp/opencode-desktop.deb
fi

# 6. Configure OpenCode
bitacora "[9/9] Configuring OpenCode settings..."
mkdir -p "${HOME}/.config/opencode"
CONFIG_FILE="${HOME}/.config/opencode/opencode.jsonc"

# Write default configuration
cat > "${CONFIG_FILE}" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "providers": {
    "anthropic": {
      "apiKey": "{env:ANTHROPIC_API_KEY}",
      "disabled": false
    },
    "openai": {
      "apiKey": "{env:OPENAI_API_KEY}",
      "disabled": false
    },
    "copilot": {
      "apiKey": "{env:GITHUB_TOKEN}"
    }
  },
  "permission": {
    "edit": "ask",
    "bash": "ask",
    "webfetch": "allow"
  }
}
EOF
chown -R "${USER}:${USER}" "${HOME}/.config/opencode"
bitacora "[9/9] OpenCode configuration file written to ${CONFIG_FILE}"

# 7. Check and configure Antigravity IDE
bitacora "[9/9] Configuring Antigravity IDE..."
if [ -d "/opt/antigravity-ide/Antigravity-IDE" ]; then
  # Ensure symbolic link is created in /usr/local/bin
  if [ ! -L "/usr/local/bin/antigravity-ide" ]; then
    sudo ln -sf /opt/antigravity-ide/Antigravity-IDE/antigravity-ide /usr/local/bin/antigravity-ide
  fi
  bitacora "[9/9] Antigravity IDE configuration completed (linked at /usr/local/bin/antigravity-ide)"
else
  bitacora "[9/9] WARNING: Antigravity IDE folder not found in /opt/antigravity-ide."
  bitacora "[9/9] Please download it manually from https://antigravity.google/download and extract it to /opt/antigravity-ide."
fi

touch "${STATE_FILE}"
bitacora "[9/9] AI and Developer tools installation complete"
