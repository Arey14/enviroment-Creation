#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/03_python_jupyter.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[3/8] SKIP: Python, uv and JupyterLab already installed"
  exit 0
fi

bitacora "[3/8] Setting up Python venv and installing packages via uv"

export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"

if [ ! -d "${VENV_PATH}" ]; then
  python3 -m venv "${VENV_PATH}"
fi

source "${VENV_PATH}/bin/activate"

# Use uv for extremely fast installation
uv pip install --upgrade pip setuptools wheel
uv pip install pandas numpy scikit-learn statsmodels scipy matplotlib seaborn plotly \
  pyarrow fastparquet openpyxl tables duckdb duckdb-engine jupysql polars \
  xgboost lightgbm optuna "tensorflow==2.16.1" "keras>=3.0.0" dask numba \
  requests selenium scrapy flask fastapi "uvicorn[standard]" mlflow dvc \
  nbconvert nb_pdf_template "nbconvert[webpdf]" black flake8 ruff python-dotenv \
  kaggle zulip pika gdown evidently pygments oauthlib jupyterlab \
  jupyterlab-git jupyterlab-spreadsheet-editor

bitacora "[3/8] Configuring JupyterLab as a User systemd service"

mkdir -p "${HOME}/.config/systemd/user"

cat > "${INSTALL_DIR}/jupyterlab.sh" << LAUNCHER
#!/bin/bash
source "${VENV_PATH}/bin/activate"
exec "${VENV_PATH}/bin/jupyter-lab" --no-browser --port=${PORT_JUPYTER} --ip=0.0.0.0 --notebook-dir="${HOME}/" --ServerApp.allow_remote_access=False
LAUNCHER
chmod u+x "${INSTALL_DIR}/jupyterlab.sh"

if ! systemctl --user is-active --quiet jupyterlab; then
  cat > "${HOME}/.config/systemd/user/jupyterlab.service" << SVCUNIT
[Unit]
Description=JupyterLab User Service
After=network.target

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/jupyterlab.sh
WorkingDirectory=${HOME}/
Restart=always
RestartSec=10
MemoryHigh=80%
MemoryMax=90%
OOMPolicy=kill

[Install]
WantedBy=default.target
SVCUNIT

  systemctl --user daemon-reload
  systemctl --user enable jupyterlab
  systemctl --user start jupyterlab
fi

touch "${STATE_FILE}"
bitacora "[3/8] Python & JupyterLab setup completed"
