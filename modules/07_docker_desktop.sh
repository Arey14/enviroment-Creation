#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/07_docker_desktop.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[7/8] SKIP: Docker and Desktop Apps already installed"
  exit 0
fi

bitacora "[7/8] Installing Docker CE and Desktop Applications"

# Docker
if ! command -v docker &>/dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "${USER}" || true
fi

# Desktop Apps
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install libreoffice

if ! command -v google-chrome &>/dev/null; then
  wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
  sudo DEBIAN_FRONTEND=noninteractive apt install -y /tmp/chrome.deb
  rm /tmp/chrome.deb
fi

if ! command -v brave-browser &>/dev/null; then
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes brave-browser
fi

if ! command -v dbeaver-ce &>/dev/null; then
  curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/dbeaver.gpg > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y dbeaver-ce
fi

if ! command -v code &>/dev/null; then
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f /tmp/packages.microsoft.gpg
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes code
fi

# VSCode extensions
code --install-extension ms-python.python || true
code --install-extension ms-python.vscode-pylance || true
code --install-extension ms-toolsai.jupyter || true
code --install-extension eamodio.gitlens || true
code --install-extension REditorSupport.r || true
code --install-extension RDebugger.r-debugger || true
code --install-extension julialang.language-julia || true
code --install-extension ms-azuretools.vscode-docker || true
code --install-extension charliermarsh.ruff || true

# Cleanup
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes update
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes dist-upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes autoremove
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes autoclean

touch "${STATE_FILE}"
bitacora "[7/8] Docker, Desktop Applications installed and cleanup complete"
