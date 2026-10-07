#!/bin/bash
# Install Savoye Connect (latest) on a Mac - the file kept in the Savoye Drive.
# Downloads the newest .dmg, CHECKS ITS SHA-256, copies the app into
# /Applications. Never needs replacing: it always fetches the latest.
set -e
BASE="https://raw.githubusercontent.com/Savoye-NA/savoye-software-releases/main"
KEY="savoye-connect"; NAME="Savoye Connect"
echo "Installing the latest $NAME..."
INFO=$(curl -fsSL "$BASE/$KEY/macos.txt") || { echo "Could not reach the download server - check the internet connection."; read -r -p "Press Return to close."; exit 1; }
VER=$(printf '%s\n' "$INFO" | sed -n 's/^version=//p'); P=$(printf '%s\n' "$INFO" | sed -n 's/^path=//p'); SHA=$(printf '%s\n' "$INFO" | sed -n 's/^sha256=//p')
TMP=$(mktemp -d); DMG="$TMP/app.dmg"
echo "Downloading $NAME $VER..."
curl -fL --progress-bar "$BASE/${P// /%20}" -o "$DMG"
GOT=$(shasum -a 256 "$DMG" | awk '{print $1}')
if [ "$GOT" != "$SHA" ]; then echo "The download did not match its fingerprint - NOT installed."; rm -rf "$TMP"; read -r -p "Press Return to close."; exit 1; fi
MNT=$(hdiutil attach -nobrowse -readonly "$DMG" | awk -F'\t' '/\/Volumes\//{print $NF; exit}')
APP=$(ls -d "$MNT"/*.app | head -1)
rm -rf "/Applications/$(basename "$APP")"
cp -R "$APP" /Applications/
hdiutil detach "$MNT" -quiet; rm -rf "$TMP"
xattr -dr com.apple.quarantine "/Applications/$(basename "$APP")" 2>/dev/null || true
echo "$NAME $VER is installed in Applications."
open "/Applications/$(basename "$APP")"
