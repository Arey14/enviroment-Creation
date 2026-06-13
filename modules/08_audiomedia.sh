#!/bin/bash
set -euo pipefail

STATE_FILE="${STATE_DIR}/08_audiomedia.done"
if [ -f "${STATE_FILE}" ]; then
  bitacora "[8/8] SKIP: Audio and Media Apps already installed"
  exit 0
fi

bitacora "[8/8] Installing Audio and Media Applications (Ubuntu Studio style)"

# 1. Add Ubuntu Studio Backports PPA to get modern/latest versions of creative suites
bitacora "[8/8] Adding Ubuntu Studio Backports PPA..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:ubuntustudio-ppa/backports

# 2. Update package lists
bitacora "[8/8] Updating package lists..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq

# 3. Install Ubuntu Studio Installer
bitacora "[8/8] Installing ubuntustudio-installer..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ubuntustudio-installer

# 4. Install creative and publishing suites
bitacora "[8/8] Installing creative apps (GIMP, Krita, Inkscape, Kdenlive, Shotcut, Blender, Natron, Darktable, RawTherapee, Audacity, Ardour, OBS Studio, LibreCAD, MyPaint, digiKam, Entangle, Rapid Photo Downloader, Handbrake, Scribus, and Calibre)..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gimp \
    krita \
    inkscape \
    kdenlive \
    shotcut \
    blender \
    natron \
    darktable \
    rawtherapee \
    audacity \
    ardour \
    obs-studio \
    librecad \
    mypaint \
    digikam \
    entangle \
    rapid-photo-downloader \
    handbrake \
    scribus \
    calibre

# 5. Configure real-time audio permissions for user
bitacora "[8/8] Configuring user real-time audio group permissions..."
sudo usermod -aG audio "${USER}" || true

# 6. Automate EULA for ubuntu-restricted-extras and install it
bitacora "[8/8] Configuring and installing ubuntu-restricted-extras (Codecs)..."
echo ttf-mscorefonts-installer msttcorefontdir/accepted-mscorefonts-eula select true | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ubuntu-restricted-extras

# 7. Note on DaVinci Resolve
bitacora "[8/8] DaVinci Resolve must be manually downloaded from Blackmagic Design's website (proprietary)."

touch "${STATE_FILE}"
bitacora "[8/8] Audio and Media Applications installation complete"
