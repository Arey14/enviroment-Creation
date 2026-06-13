#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/06_julia.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[6/8] SKIP: Julia already installed"
  exit 0
fi

bitacora "[6/8] Installing Julia via juliaup"

if ! command -v julia &>/dev/null; then
  curl -fsSL https://install.julialang.org | sh -s -- --yes
  export PATH="${HOME}/.juliaup/bin:${PATH}"
fi

cat > "${INSTALL_DIR}/instalar_paquetes_julia.jl" << 'JLSCRIPT'
using Pkg
Pkg.add([
  "CSV", "DataFrames", "PooledArrays", "Distributions", "Random", "HTTP",
  "XGBoost", "DecisionTree", "LightGBM", "BayesianOptimization", 
  "GaussianProcesses", "MLFlowClient", "IJulia"
])
JLSCRIPT

julia "${INSTALL_DIR}/instalar_paquetes_julia.jl"

touch "${STATE_FILE}"
bitacora "[6/8] Julia packages installed"
