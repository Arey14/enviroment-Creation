# Environment Creation Framework

Este repositorio contiene un framework modular de automatización para la instalación, configuración y optimización de entornos de desarrollo y suites creativas sobre **Ubuntu**. 

El flujo está diseñado para ser totalmente desatendido (no interactivo), modular y resiliente a fallas utilizando un mecanismo de guardado de estado que permite reanudar el proceso en caso de interrupción.

---

## Arquitectura del Proyecto

La estructura de archivos está organizada de la siguiente manera:

```text
├── main.sh                  # Script maestro que orquesta el flujo de ejecución
└── modules/                 # Directorio que contiene los módulos de instalación
    ├── 01_base_system.sh    # Utilidades base del sistema y paquetes iniciales
    ├── 02_sysstat_swap.sh   # Monitoreo de recursos y asignación de Swap virtual
    ├── 03_python_jupyter.sh # Entorno Python virtualizado, JupyterLab y dependencias
    ├── 04_r_rstudio.sh      # Lenguaje R, paquetes científicos y RStudio Server
    ├── 05_mlflow.sh         # Servidor y UI de MLflow como servicio de usuario
    ├── 06_julia.sh          # Entorno Juliaup, lenguaje Julia y paquetes básicos
    ├── 07_docker_desktop.sh # Docker Engine, herramientas de oficina y navegadores
    ├── 08_audiomedia.sh     # Suites de diseño gráfico, modelado 3D y edición de audio/video
    └── 09_ai_dev_tools.sh   # Publicación científica, agentes de IA (OpenCode, Antigravity IDE) y descargas
```

---

## Mecanismos Clave de Diseño

### 1. Control de Estado y Resiliencia (Resume feature)
Cada módulo genera un archivo de marca (`.done`) en la ruta `${STATE_DIR}` una vez que finaliza con éxito. Si la instalación se detiene por cualquier motivo (ej. pérdida de conexión, reinicio), al volver a ejecutar `./main.sh` se omitirán (`SKIP`) los pasos ya completados, permitiendo reanudar la instalación de forma segura y veloz.

### 2. Registro e Historial Unificado (`bitacora`)
El framework define una función global de logging llamada `bitacora` que antepone la fecha y hora a cada mensaje. Además, redirecciona de forma global las salidas estándar (`stdout`) y de error (`stderr`) hacia un archivo de bitácora unificado (`LOG_FILE`) ubicado en `${HOME}/install/log_install.txt`.

### 3. Ejecución No Interactiva
Para garantizar que la instalación se complete sin intervención del usuario en terminales remotas o integraciones continuas, se hace uso sistemático de variables de entorno y utilidades como:
- `DEBIAN_FRONTEND=noninteractive` para evitar diálogos de APT.
- `debconf-set-selections` para aceptar automáticamente licencias propietarias o EULAs (como en el caso de las tipografías de Microsoft en `ubuntu-restricted-extras`).

---

## Guía Detallada de los Módulos

### [01_base_system.sh](modules/01_base_system.sh)
Instala dependencias esenciales del sistema de compilación (`build-essential`), bibliotecas de desarrollo criptográfico y geoespacial, el gestor de paquetes de Python ultrarrápido `uv`, y herramientas cotidianas (`tmux`, `git`, `htop`, `ffmpeg`).

### [02_sysstat_swap.sh](modules/02_sysstat_swap.sh)
Configura el demonio de recolección de estadísticas del sistema `sysstat` en intervalos de 5 minutos para monitorizar el uso de recursos históricos.

### [03_python_jupyter.sh](modules/03_python_jupyter.sh)
Crea un entorno virtual (`.venv`) y utiliza `uv` para instalar suites de ciencia de datos, machine learning (TensorFlow, Keras, PyTorch/LightGBM, pandas) y utilidades de backend. Adicionalmente, instala e implementa JupyterLab como un servicio de sistema (`systemd --user`).

### [04_r_rstudio.sh](modules/04_r_rstudio.sh)
Configura el repositorio oficial de CRAN para R y el gestor de paquetes paralelo `pak`. Instala RStudio Server y re-asigna sus puertos de comunicación para no generar conflictos en el servidor.

### [05_mlflow.sh](modules/05_mlflow.sh)
Configura e inicia un servidor local de MLflow con persistencia en SQLite y almacenamiento de artefactos local, exponiéndolo mediante un servicio de `systemd --user`.

### [06_julia.sh](modules/06_julia.sh)
Instala Julia de manera recomendada mediante `juliaup`, agrega soporte interactivo para Jupyter (IJulia) y descarga las librerías matemáticas y de análisis de datos más populares del lenguaje.

### [07_docker_desktop.sh](modules/07_docker_desktop.sh)
Instala Docker Engine oficial con permisos automáticos para el usuario actual. También instala software de uso diario como LibreOffice, Google Chrome, Brave Browser, DBeaver CE y Visual Studio Code (junto con sus extensiones clave para Python, R y Docker).

### [08_audiomedia.sh](modules/08_audiomedia.sh)
Configura las herramientas creativas en sus versiones más actuales utilizando el PPA oficial de **Ubuntu Studio Backports** y habilita soporte de audio de baja latencia asignando al usuario en el grupo de permisos de tiempo real `audio` (indispensable para PipeWire/JACK con Ardour y Audacity). Instala:
- **Diseño Gráfico / Ilustración / Pintura**: GIMP, Krita, Inkscape, MyPaint.
- **Modelado 3D / CAD / VFX**: Blender, Natron, LibreCAD.
- **Fotografía**: Darktable, RawTherapee, digiKam, Entangle, Rapid Photo Downloader.
- **Edición de Video / Audio / Captura**: Kdenlive, Shotcut, Audacity, Ardour, OBS Studio, Handbrake.
- **Publicación Editorial / Lectura**: Scribus, Calibre.
- **Códecs**: `ubuntu-restricted-extras` con aceptación automática de EULA.

### [09_ai_dev_tools.sh](modules/09_ai_dev_tools.sh)
Instala y configura herramientas de productividad para Inteligencia Artificial y publicación técnica:
- **Publicación científica**: Instala Quarto CLI (última versión de GitHub) para la redacción de informes técnicos y presentaciones.
- **Agentes de IA**: Instala el CLI de OpenCode y OpenCode Desktop, y genera una plantilla de configuración global en `~/.config/opencode/opencode.jsonc` con soporte para OpenAI, Anthropic y GitHub Copilot.
- **Entorno de Desarrollo**: Enlaza simbólicamente la instalación de Antigravity IDE a `/usr/local/bin` si se encuentra extraída en `/opt/antigravity-ide`.
- **Utilidades de Medios**: Instala el binario actualizado de `yt-dlp` en `/usr/local/bin` y asegura la presencia de `ffmpeg` para procesamiento multimedia.

---

## Cómo Ejecutar

Para iniciar el flujo completo, simplemente clona el repositorio y ejecuta:

```bash
chmod +x main.sh modules/*.sh
./main.sh
```

### Monitorear el progreso en tiempo real:
```bash
tail -f ~/install/log_install.txt
```
