#!/bin/bash
set -euo pipefail

export INSTALL_DIR="${HOME}/install"
export STATE_DIR="${INSTALL_DIR}/state"
export LOG_FILE="${INSTALL_DIR}/log_install.txt"
export VENV_PATH="${HOME}/.venv"
export MLFLOW_DIR="${HOME}/mlflow"
export R_LIBS_USER="${HOME}/.local/lib/R/site-library"

export PORT_JUPYTER=9999
export PORT_RSTUDIO=9898
export PORT_MLFLOW=5050

export MAKEFLAGS="-j$(nproc)"
export UBUNTU_CODENAME=$(lsb_release -cs)

mkdir -p "${STATE_DIR}"
mkdir -p "${HOME}/Downloads/Compressed" "${HOME}/Downloads/Documents" "${HOME}/Downloads/Programs" "${HOME}/Downloads/Videos"


# Global logging redirection
exec > >(tee -i "${LOG_FILE}") 2>&1

bitacora() {
  local fecha=$(date +"%Y%m%d %H%M%S")
  echo "${fecha}  $1"
}
export -f bitacora

MODULES_DIR="$(dirname "$0")/modules"
MODULES=(
  "01_base_system.sh"
  "02_sysstat_swap.sh"
  "03_python_jupyter.sh"
  "04_r_rstudio.sh"
  "05_mlflow.sh"
  "06_julia.sh"
  "07_docker_desktop.sh"
  "08_audiomedia.sh"
  "09_ai_dev_tools.sh"
)

bitacora "START Modular Installation (Ubuntu ${UBUNTU_CODENAME})"

for mod in "${MODULES[@]}"; do
  MOD_PATH="${MODULES_DIR}/${mod}"
  if [ -x "${MOD_PATH}" ]; then
    "${MOD_PATH}"
  else
    bitacora "ERROR: Module ${mod} not found or not executable."
    exit 1
  fi
done

bitacora "END Modular Installation"
echo "Installation complete. Check ${LOG_FILE} for details."
