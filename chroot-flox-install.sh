#!/bin/bash
set -euxo pipefail

# Create a nixuser
useradd -m -s /bin/bash nixuser

# Create the /nix directory
mkdir -m 0755 -p /nix

# Set up Nix configuration
mkdir /home/nixuser/.config
mkdir /home/nixuser/.config/nix
echo "                          
experimental-features = nix-command flakes
" > /home/nixuser/.config/nix/nix.conf

# Set ownership of /nix to the nixuser
chown -R nixuser /nix

# Install Nix package manager
runuser -l nixuser -c 'sh <(curl -L https://nixos.org/nix/install) --no-daemon'

# Set permissions so all users can access /nix
#chown -R root:nix-users /nix
chmod -R 1775 /nix

# Set up the paths to launch nix commands
ln -s /home/nixuser/.nix-profile/bin/nix /usr/local/bin/nix  && ln -s /home/nixuser/.nix-profile/bin/nix-shell /usr/local/bin/nix-shell && ln -s /home/nixuser/.nix-profile/bin/nix-env /usr/local/bin/nix-env

# Install flox using nix
chown -R nixuser:nixuser /nix
runuser -l nixuser -c '. "/home/nixuser/.nix-profile/etc/profile.d/nix.sh" && nix --extra-experimental-features "nix-command flakes" profile install --accept-flake-config github:flox/flox/v1.4.4'

# Symlink flox to /usr/local/bin for global access
ln -sf /home/nixuser/.nix-profile/bin/flox /usr/local/bin/flox

set +x