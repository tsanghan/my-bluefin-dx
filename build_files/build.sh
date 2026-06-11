#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y thinkfan
echo "options thinkpad_acpi fan_control=1" | tee /etc/modprobe.d/thinkfan.conf
echo 'install_items+=" /etc/modprobe.d/thinkfan.conf "' | tee /etc/dracut.conf.d/install_items.conf

KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | \
    grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | \
    sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"

export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly \
                --kver "$QUALIFIED_KERNEL" \
                --reproducible -v \
                --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
mkdir /var/nix
ln -s /var/nix /nix

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable thinkfan
systemctl enable podman.socket
