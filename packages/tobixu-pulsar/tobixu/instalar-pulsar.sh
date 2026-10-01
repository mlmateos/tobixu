#!/bin/bash
MARKER="$HOME/.tobixu-pulsar-done"
[ -f "$MARKER" ] && exit 0
PULSAR_DEB="/tmp/pulsar-amd64.deb"
PULSAR_URL="https://github.com/pulsar-edit/pulsar/releases/download/v1.132.1/Pulsar.1.132.1-amd64.deb"
for i in 1 2 3; do
    if wget -q --show-progress -O "$PULSAR_DEB" "$PULSAR_URL"; then
        sudo dpkg -i "$PULSAR_DEB" || sudo apt-get install -f -y
        date -Is > "$MARKER"
        rm -f "$PULSAR_DEB"
        exit 0
    fi
    sleep 2
done
