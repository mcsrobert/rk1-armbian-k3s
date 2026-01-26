#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE="$1"
LINUXFAMILY="$2"
BOARD="$3"
BUILD_DESKTOP="$4"


set_armbian_env() {
    local key="$1"
    local value="$2"
    local file="/boot/armbianEnv.txt"

    if grep -q "^${key}=" "$file"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$file"
    else
        echo "${key}=${value}" >> "$file"
    fi
}

set_armbian_env "extraargs" "cgroup_memory=1 cgroup_enable=memory"
set_armbian_env "overlays" "rockchip-npu"


set_sshd_param() {
    local key="$1"
    local value="$2"
    local file="/etc/ssh/sshd_config"

    if grep -qE "^#?${key}" "$file"; then
        sed -i -E "s|^#?${key}([[:space:]]+).*|${key} ${value}|" "$file"
    else
        echo "${key} ${value}" >> "$file"
    fi
}

set_sshd_param "PermitRootLogin" "prohibit-password"
set_sshd_param "PasswordAuthentication" "no"
set_sshd_param "ChallengeResponseAuthentication" "no"
set_sshd_param "KbdInteractiveAuthentication" "no"
set_sshd_param "PermitEmptyPasswords" "no"
