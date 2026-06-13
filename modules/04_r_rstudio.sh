#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/04_r_rstudio.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[4/8] SKIP: R and RStudio already installed"
  exit 0
fi

bitacora "[4/8] Installing R via CRAN"

mkdir -p "${R_LIBS_USER}"
echo "R_LIBS_USER=${R_LIBS_USER}" > "${HOME}/.Renviron"

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends software-properties-common dirmngr
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc > /dev/null
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes "deb https://cloud.r-project.org/bin/linux/ubuntu ${UBUNTU_CODENAME}-cran40/" || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends r-base r-base-dev

bitacora "[4/8] Installing R packages using 'pak' for parallel execution"
# Using pak for high performance
Rscript -e 'if (!require("pak", quietly = TRUE)) install.packages("pak", repos = "https://cloud.r-project.org/")'

cat > "${INSTALL_DIR}/instalar_paquetes_r.r" << 'RSCRIPT'
pak::pkg_install(c(
  "data.table", "httr", "devtools", "remotes", "IRkernel", "styler", "lintr",
  "yaml", "rlist", "microbenchmark", "magrittr", "stringi", "curl", "Rcpp",
  "Matrix", "glm2", "ROCR", "MASS", "openssl", "roxygen2", "rsvg", "DiagrammeRsvg",
  "DiagrammeR", "visNetwork", "ggplot2", "plotly", "rpart", "rpart.plot", "ranger",
  "randomForest", "caret", "mlr3", "mlr3mbo", "mlr3learners", "mlr3tuning", "bbotk",
  "dplyr", "tidyr", "tidymodels", "DiceKriging", "mlrMBO", "ParBayesianOptimization",
  "SHAPforxgboost", "shapr", "iml", "RhpcBLASctl", "synchronicity", "modules", "primes",
  "mlflow", "shiny", "languageserver", "treeClust", "xgboost", "lightgbm"
))

# CatBoost
catboost_ver <- Sys.getenv("CATBOOST_VERSION", unset = "1.2.9")
catboost_url <- sprintf("https://github.com/catboost/catboost/releases/download/v%s/catboost-R-Linux-%s.tgz", catboost_ver, catboost_ver)
pak::pkg_install(catboost_url)

# LightGBM Explainer
pak::pkg_install("lantanacamara/lightgbmExplainer")
RSCRIPT

CATBOOST_VERSION="1.2.10" Rscript "${INSTALL_DIR}/instalar_paquetes_r.r"

bitacora "[4/8] Registering IRkernel in existing Jupyter environment"
if [ -d "${VENV_PATH}" ]; then
  source "${VENV_PATH}/bin/activate"
  Rscript -e 'IRkernel::installspec(user = FALSE)'
fi

bitacora "[4/8] Installing RStudio Server (Jammy fallback)"
if ! systemctl is-active --quiet rstudio-server; then
  # Always use 'jammy' deb package as it installs fine in newer Ubuntu versions
  RSTUDIO_PACK="rstudio-server-2026.05.0-218-amd64.deb"
  wget -q "https://download2.rstudio.org/server/jammy/amd64/${RSTUDIO_PACK}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes ./"${RSTUDIO_PACK}"
  rm "${RSTUDIO_PACK}"
  
  sudo mkdir -p /etc/rstudio
  if ! grep -q "www-port=${PORT_RSTUDIO}" /etc/rstudio/rserver.conf 2>/dev/null; then
    echo "www-port=${PORT_RSTUDIO}" | sudo tee -a /etc/rstudio/rserver.conf > /dev/null
  fi
  sudo rstudio-server restart
fi

touch "${STATE_FILE}"
bitacora "[4/8] R and RStudio Server installed"
