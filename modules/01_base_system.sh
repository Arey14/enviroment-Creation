#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/01_base_system.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[1/8] SKIP: Base system packages already installed"
  exit 0
fi

bitacora "[1/8] Installing base system packages"

sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  apt-transport-https ca-certificates gnupg software-properties-common

sudo DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install build-essential

# Default python3 will be used
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  libssl-dev apt-utils libcurl4-openssl-dev libxml2-dev \
  libgeos-dev libproj-dev libgdal-dev librsvg2-dev \
  ocl-icd-opencl-dev libmagick++-dev libsodium-dev \
  libharfbuzz-dev libfribidi-dev pandoc \
  texlive texlive-xetex texlive-fonts-recommended texlive-latex-recommended \
  cmake gdebi curl sshpass nano htop iotop iputils-ping \
  cron tmux git zip unzip sysstat rsync \
  libudunits2-dev inotify-tools libssh2-1-dev libgit2-dev ffmpeg \
  python3 python3-venv python3-pip python3-dev ipython3 libhiredis-dev

if apt-cache show libv8-dev &>/dev/null; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install libv8-dev
else
  sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install libnode-dev
fi

# Install uv globally via script to speed up python package installs
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.cargo/bin:${PATH}"
fi

touch "${STATE_FILE}"
bitacora "[1/8] Base system packages installed"
