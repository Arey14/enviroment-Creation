#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/05_mlflow.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[5/8] SKIP: MLFlow already configured"
  exit 0
fi

bitacora "[5/8] Configuring MLflow UI as a User systemd service"

mkdir -p "${MLFLOW_DIR}"
mkdir -p "${HOME}/.config/systemd/user"

cat > "${INSTALL_DIR}/mlflow_ui.sh" << MLFLOW_LAUNCHER
#!/bin/bash
source "${VENV_PATH}/bin/activate"
exec "${VENV_PATH}/bin/mlflow" ui \
  --backend-store-uri "sqlite:///${MLFLOW_DIR}/mlflow.db" \
  --default-artifact-root "${MLFLOW_DIR}/artifacts" \
  --host 0.0.0.0 \
  --port ${PORT_MLFLOW}
MLFLOW_LAUNCHER
chmod u+x "${INSTALL_DIR}/mlflow_ui.sh"

if ! systemctl --user is-active --quiet mlflow_ui; then
  cat > "${HOME}/.config/systemd/user/mlflow_ui.service" << SVCUNIT
[Unit]
Description=MLflow UI User Service
After=network.target

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/mlflow_ui.sh
WorkingDirectory=${HOME}/
Restart=always
RestartSec=10
MemoryHigh=60%
MemoryMax=70%

[Install]
WantedBy=default.target
SVCUNIT

  systemctl --user daemon-reload
  systemctl --user enable mlflow_ui
  systemctl --user start mlflow_ui
fi

touch "${STATE_FILE}"
bitacora "[5/8] MLFlow UI running as service"
