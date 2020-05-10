#!/bin/bash -e

#sed -i "s/rootwait/& modules-load=dwc2,g_ether/" "${ROOTFS_DIR}/boot/cmdline.txt"

on_chroot << EOF
systemctl disable hciuart
EOF

echo "
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
" >> "${ROOTFS_DIR}/etc/dhcpcd.conf"

mv "${ROOTFS_DIR}/etc/dnsmasq.conf" "${ROOTFS_DIR}/etc/dnsmasq.conf.orig"

install -v -m 655 files/dnsmasq.conf	"${ROOTFS_DIR}/etc/"

install -v -d					"${ROOTFS_DIR}/etc/hostapd"
install -v -m 655 files/hostapd.conf	"${ROOTFS_DIR}/etc/hostapd/"

echo "
ssid=${SSID}
wpa_passphrase=${WPA_PASSPHRASE}
" >> "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> "${ROOTFS_DIR}/etc/default/hostapd"

echo "192.168.4.1	reversed.lan" >> "${ROOTFS_DIR}/etc/hosts"

on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
EOF

on_chroot apt-key add - < files/reversed-ppa.gpg.key
install -v -m 655 files/reversed.list	"${ROOTFS_DIR}/etc/apt/sources.list.d/"
on_chroot << EOF
apt update
EOF
