#!/bin/sh
set -eu

src="$(cd "$(dirname "$0")" && pwd)"
dest="${XDG_CONFIG_HOME:-$HOME/.config}/DankMaterialShell/plugins/QuickClock"

mkdir -p "$(dirname "$dest")"
rm -rf "$dest"
ln -s "$src" "$dest"

echo "Linked $dest -> $src"
dms ipc call plugin-scan scan 2>/dev/null || echo "Shell not running; the plugin loads on next start"
echo "Enable with: dms ipc call plugins enable quickClock"
