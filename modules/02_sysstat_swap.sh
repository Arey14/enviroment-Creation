#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/02_sysstat_swap.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[2/8] SKIP: sysstat and swap already configured"
  exit 0
fi

bitacora "[2/8] Configuring sysstat and swap"

# Sysstat
if [ -f /etc/default/sysstat ]; then
  sudo sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
fi

sudo mkdir -p /etc/systemd/system/sysstat-collect.timer.d
cat <<EOF | sudo tee /etc/systemd/system/sysstat-collect.timer.d/override.conf > /dev/null
[Timer]
OnCalendar=
OnCalendar=*:00/5
EOF

if [ -f /etc/cron.d/sysstat ]; then
  sudo sed -i 's/5-55\/10/\*\/5/' /etc/cron.d/sysstat
fi

sudo systemctl daemon-reload
sudo systemctl enable --now sysstat
sudo systemctl restart sysstat-collect.timer || true

# Swap
if [ "$(sudo swapon --show | wc -l)" -eq 0 ]; then
  RAM_GB=$(awk '{ printf "%.0f", $2/1024/1024; exit }' /proc/meminfo)
  SWAP_GB=$(( RAM_GB < 16 ? RAM_GB : 16 ))
  
  if [ ! -f /swapfile ]; then
    bitacora "[2/8] Creating ${SWAP_GB} GB swap file"
    sudo fallocate -l "${SWAP_GB}G" /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
  fi
fi

touch "${STATE_FILE}"
bitacora "[2/8] sysstat and swap configured"
