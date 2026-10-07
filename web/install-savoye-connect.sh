#!/bin/bash
# Install Savoye Connect (latest) on Linux (Debian / Ubuntu) - the file kept in
# the Savoye Drive. Downloads the newest .deb, CHECKS ITS SHA-256, installs
# it with apt. Never needs replacing: it always fetches the latest.
#   Run:  bash install-savoye-connect.sh
set -e
BASE="https://raw.githubusercontent.com/Savoye-NA/savoye-software-releases/main"
KEY="savoye-connect"; NAME="Savoye Connect"
INFO=$(curl -fsSL "$BASE/$KEY/linux.txt") || { echo "Could not reach the download server."; exit 1; }
VER=$(printf '%s\n' "$INFO" | sed -n 's/^version=//p'); P=$(printf '%s\n' "$INFO" | sed -n 's/^path=//p'); SHA=$(printf '%s\n' "$INFO" | sed -n 's/^sha256=//p')
TMP=$(mktemp -d); DEB="$TMP/$(basename "$P")"
echo "Downloading $NAME $VER..."
curl -fL --progress-bar "$BASE/${P// /%20}" -o "$DEB"
echo "$SHA  $DEB" | sha256sum -c --quiet || { echo "The download did not match its fingerprint - NOT installed."; exit 1; }
sudo apt-get install -y "$DEB"
rm -rf "$TMP"
echo "$NAME $VER is installed."
