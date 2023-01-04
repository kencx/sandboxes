#!/bin/bash

set -eux

echo "Cleaning pacman cache"
yes | pacman -Scc --noconfirm
