#!/bin/sh

set -e
set -x

install_default_software () {
    apt-get update
    apt-get dist-upgrade --yes

    apt-get install --yes \
        cryptsetup \
        curl \
        htop \
        samba \
        sshfs \
        wget
}

init_configuration () {
    timedatectl set-timezone Europe/Berlin

    cp -v /provisioning/etc/rsyslog.d/* /etc/rsyslog.d
    systemctl restart rsyslog
}

init_samba () {
    adduser --disabled-login --no-create-home --shell /bin/false --system data

    smb_password=$(cat /etc/remotebackup/smb_password.txt)

    printf "$smb_password\n$smb_password" | smbpasswd -as data
    printf "$smb_password\n$smb_password" | smbpasswd -as root

    mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
    ln -s /provisioning/etc/samba/smb.conf /etc/samba

    systemctl restart smbd
}

init_services () {
    ln -sv /provisioning/etc/systemd/system/* /etc/systemd/system
}

init_sysctl () {
    cp -v /provisioning/etc/sysctl.d/*.conf /etc/sysctl.d
    systemctl restart systemd-sysctl
}

init_users () {
    ln -sv /etc/remotebackup/settings.sh /etc/profile.d
    ln -sv /provisioning/etc/profile.d/*.sh /etc/profile.d

    . /etc/profile
}

main () {
    init_configuration
    init_users
    init_services
    init_sysctl
    install_default_software
    init_samba
}

main
