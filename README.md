# Environment Creation Framework

This repository provides a modular automation framework to install, configure, and optimize development environments and media tools on Ubuntu.

The execution flow is designed to be non-interactive, modular, and resilient using a state-tracking mechanism that allows resuming the installation if interrupted.

---

## Project Architecture

The directory structure is organized as follows:

```text
├── main.sh                  # Master script that orchestrates the execution flow
└── modules/                 # Directory containing the installation modules
    ├── 01_base_system.sh    # Base system packages and development utilities
    ├── 02_sysstat_swap.sh   # System resource monitoring setup
    ├── 03_python_jupyter.sh # Python virtual environment, JupyterLab, and libraries
    ├── 04_r_rstudio.sh      # R language, scientific packages, and RStudio Server
    ├── 05_mlflow.sh         # Local MLflow server managed as a user systemd service
    ├── 06_julia.sh          # Julia language environment setup via juliaup
    ├── 07_docker_desktop.sh # Docker Engine, desktop applications, and IDEs
    ├── 08_audiomedia.sh     # Graphic design, 3D modeling, and audio/video software
    └── 09_ai_dev_tools.sh   # Scientific publishing, AI agents, and download utilities
```

---

## Key Design Mechanisms

### 1. State Control and Resilience (Resume Feature)
Each module creates a `.done` state file in `${STATE_DIR}` upon successful completion. If execution is interrupted, re-running `./main.sh` skips already executed modules.

### 2. Unified Logging
The framework defines a global logging function (`bitacora`) that prefixes timestamps to log messages. It redirects `stdout` and `stderr` to a single log file at `${LOG_FILE}`.

### 3. Non-Interactive Execution
To ensure headless execution, the framework configures:
- `DEBIAN_FRONTEND=noninteractive` to bypass APT prompts.
- `debconf-set-selections` to accept license agreements (such as Microsoft fonts in `ubuntu-restricted-extras`).

---

## Module Reference Guide

### [01_base_system.sh](modules/01_base_system.sh)
Installs build essential tools, development libraries, the `uv` package manager, and utilities (`tmux`, `git`, `htop`, `ffmpeg`).

### [02_sysstat_swap.sh](modules/02_sysstat_swap.sh)
Configures the `sysstat` collector at 5-minute intervals to record historical resource utilization.

### [03_python_jupyter.sh](modules/03_python_jupyter.sh)
Creates a Python virtual environment (`.venv`) and uses `uv` to install scientific and machine learning libraries (TensorFlow, Keras, PyTorch, LightGBM, pandas). It also configures JupyterLab as a `systemd --user` service.

### [04_r_rstudio.sh](modules/04_r_rstudio.sh)
Configures the official CRAN repository, installs R packages via `pak`, and sets up RStudio Server with custom port assignments.

### [05_mlflow.sh](modules/05_mlflow.sh)
Sets up a local MLflow tracking server with SQLite storage and configures it as a `systemd --user` service.

### [06_julia.sh](modules/06_julia.sh)
Installs Julia via `juliaup`, configures the Jupyter kernel (IJulia), and installs numerical packages.

### [07_docker_desktop.sh](modules/07_docker_desktop.sh)
Installs Docker Engine, configures user permissions, and installs desktop software (LibreOffice, Chrome, Brave, DBeaver CE, and Visual Studio Code with language extensions).

### [08_audiomedia.sh](modules/08_audiomedia.sh)
Configures creative suites using the Ubuntu Studio Backports PPA and assigns the user to the `audio` group for real-time processing permissions. Installs:
- **Graphics & Painting**: GIMP, Krita, Inkscape, MyPaint.
- **3D Modeling & CAD**: Blender, Natron, LibreCAD.
- **Photography**: Darktable, RawTherapee, digiKam, Entangle, Rapid Photo Downloader.
- **Audio & Video Editing**: Kdenlive, Shotcut, Audacity, Ardour, OBS Studio, Handbrake.
- **Publishing & E-books**: Scribus, Calibre.
- **Codecs**: `ubuntu-restricted-extras` with automated EULA acceptance.

### [09_ai_dev_tools.sh](modules/09_ai_dev_tools.sh)
Installs and configures tools for AI workflows and scientific reporting:
- **Scientific Publishing**: Installs Quarto CLI for document and presentation authoring.
- **AI Agents**: Installs OpenCode CLI and OpenCode Desktop, and writes the global configuration file at `~/.config/opencode/opencode.jsonc` supporting OpenAI, Anthropic, and GitHub Copilot.
- **IDE Integration**: Creates a symbolic link for Antigravity IDE in `/usr/local/bin` if it is present in `/opt/antigravity-ide`.
- **Media Utilities**: Installs `yt-dlp` in `/usr/local/bin` and ensures `ffmpeg` is present.

---

## Execution Guide

Clone the repository and run:

```bash
chmod +x main.sh modules/*.sh
./main.sh
```

### Monitor progress:
```bash
tail -f ~/install/log_install.txt
```
