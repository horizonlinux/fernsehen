#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

bash -c 'cat > /usr/lib/sysusers.d/networkmanager-vpn.conf << EOF
u nm-openconnect - "NetworkManager user for OpenConnect"
g nm-openconnect -
u nm-openvpn - "NetworkManager user for OpenVPN"
g nm-openvpn -
u nm-fortisslvpn - "NetworkManager user for FortiSSLVPN"
g nm-fortisslvpn -
u sstpc - "NetworkManager user for SSTP"
g sstpc -
EOF'
bash -c 'cat > /usr/lib/tmpfiles.d/custom-networkmanager-vpn.conf << EOF
d /run/pptp 0750 root root -
d /var/lib/AccountsService 0775 root root -
d /var/lib/AccountsService/icons 0775 root root -
d /var/lib/AccountsService/users 0700 root root -
d /var/lib/NetworkManager-fortisslvpn 0700 root root -
EOF'
bash -c 'cat > /usr/lib/tmpfiles.d/custom.conf << EOF
L+ /run/run - - - - ../run
d /run/pptp 0750 root root -
d /var/lib/containers 0755 root root -
d /var/lib/dnf 0755 root root -
d /var/lib/dnf/repos 0755 root root -
L /run/run - - - - ../run
d /run/pptp 0750 root root - -
d /var/lib/dnf/repos/fedora-f8e7c8bda68a349e 0755 root root - -
d /var/lib/dnf/repos/updates-79babcf8637033ce 0755 root root - -
d /var/lib/ipsec 0700 root root - -
d /run/pptp 0750 root root - -
d /var/lib/ipsec/nss 0700 root root - -
d /var/lib/openvpn 0770 openvpn openvpn - -
d /var/lib/tpm2-tss 0755 root root - -
d /run/pptp 0750 root root - -
d /var/lib/tpm2-tss/system 0755 root root - -
d /var/lib/tuned 0755 root root - -
d /var/usrlocal/bin 0755 root root - -
d /run/pptp 0750 root root - -
d /var/usrlocal/etc 0755 root root - -
d /var/usrlocal/games 0755 root root - -
d /var/usrlocal/include 0755 root root - -
EOF'
systemd-tmpfiles --create
systemd-sysusers
