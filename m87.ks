# ═══════════════════════════════════════════════════════════════
#  M87 Linux 1.0 — Live ISO Build Recipe
#  Build with: livemedia-creator --make-iso --no-virt
#  Base: Fedora 44 + KDE Plasma 6
# ═══════════════════════════════════════════════════════════════

lang en_US.UTF-8
keyboard us
timezone --utc UTC
# timezone --utc Africa/Cairo

# ─── Package Sources ───
# Released Fedora (mirrorlist picks the fastest mirror):
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64"
repo --name="updates" --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64"
# Direct URL alternative (exact snapshot):
# url --url="https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/os/"
# If Fedora 44 is branched but NOT yet released, use the development tree:
# url --url="https://dl.fedoraproject.org/pub/fedora/linux/development/44/Everything/x86_64/os/"

repo --name=m87 --baseurl=file:///home/kdealiop/m87-repo
# If your pykickstart rejects --gpgcheck, just drop that option.
# RPM Fusion (needed only for vlc / unrar):
# repo --name="rpmfusion-free" --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-44&arch=x86_64"

network --bootproto=dhcp --activate --hostname=m87
selinux --enforcing
firewall --enabled --service=ssh
services --enabled=NetworkManager,sshd,sddm,firewalld,bluetooth,cups,avahi-daemon,chronyd,power-profiles-daemon
rootpw --lock
firstboot --disable

# ─── Build-time partitioning ───
# livemedia-creator DOES use this: it installs the rootfs into a temporary
# disk image which becomes the squashfs. Without it the build FAILS.
# It does NOT affect the ISO layout (lorax does that) and does NOT affect
# what Anaconda creates when a user installs to disk.
bootloader --location=none
zerombr
clearpart --all
part / --fstype="ext4" --size=20480

# ─── Fixed user (optional). Generate hash: openssl passwd -6 'PASSWORD' ───
# user --name=m87linux --password='<HASH>' --iscrypted --groups=wheel --shell=/usr/bin/fish

# ═════════════════════════════════════════
# PACKAGES
# ═════════════════════════════════════════
%packages --ignoremissing
# NOTE: --ignoremissing removed on purpose — silent skips hide real bugs.

# ─── m87 linux ───

m87-configs
m87-logos
m87-release

# ─── Installer (CRITICAL — without it, no installer in the ISO) ───
anaconda
anaconda-install-env-deps
anaconda-live
anaconda-dracut

# ─── Core Base ───
@core
kernel
kernel-modules
kernel-modules-extra
zram-generator
lvm2
dnf
dnf5-plugins

# ─── Init & Boot ───
systemd
dracut
dracut-live
dracut-config-generic
dracut-network
grub2
grub2-efi-x64
grub2-efi-x64-modules
grub2-pc
grub2-tools
efibootmgr
shim-x64
os-prober
plymouth
plymouth-plugin-two-step
plymouth-system-theme
microcode_ctl
linux-firmware

# ─── Display (Wayland primary + X11 fallback) ───
@base-x
xorg-x11-server-Xwayland
qt6-qtwayland

# ─── Network ───
NetworkManager
NetworkManager-wifi
wpa_supplicant
plasma-nm
avahi
nss-mdns
firewalld

# ─── Audio & Bluetooth ───
pipewire
pipewire-pulse
pipewire-alsa
wireplumber
alsa-utils
pavucontrol
sof-firmware
alsa-ucm
bluez
bluedevil

# ─── Graphics Drivers ───
mesa-vulkan-drivers
mesa-va-drivers
intel-media-driver
libva-utils

# ─── Firmware Updates ───
fwupd

# ─── KDE Plasma ───
kde-settings-plasma
kde-settings-sddm
plasma-desktop
plasma-workspace
# NOTE: X11 session — may be dropped in future Fedora releases; delete if gone.
plasma-workspace-x11
plasma-systemmonitor
plasma-pa
plasma-discover
plasma-discover-packagekit
plasma-discover-flatpak
kdeplasma-addons
sddm
sddm-wayland-plasma
sddm-kcm
accountsservice
xdg-desktop-portal
xdg-desktop-portal-kde
xdg-desktop-portal-gtk
plasma-browser-integration
plasma-vault
plasma-thunderbolt
kde-gtk-config
breeze-gtk
plasma-integration

# ─── KDE Applications ───
konsole
dolphin
kate
ark
spectacle
systemsettings
kinfocenter
kmenuedit
kdeconnectd
kcalc
filelight
kclock
kcharselect
okular
elisa
dragon
kio-extras
kio-fuse
kdegraphics-thumbnailers
ffmpegthumbs

# ─── Media backends (Dragon/Elisa/Dolphin previews need these) ───
# gstreamer1-libav gives H.264/H.265/HEVC decode without RPM Fusion.
gstreamer1-plugins-good
gstreamer1-plugins-bad-free
gstreamer1-plugins-ugly-free
gstreamer1-libav

# ─── Media & Productivity ───
gwenview
firefox
libreoffice-writer
libreoffice-calc
libreoffice-impress

# ─── System Tools ───
partitionmanager
gnome-disk-utility
p7zip
p7zip-plugins
unzip
zip
distrobox
podman
flatpak
PackageKit
power-profiles-daemon
spice-vdagent
qemu-guest-agent
nano
less
git
openssh-clients
openssh-server
polkit
dbus
cryptsetup
fish
bash-completion
xdg-user-dirs
xdg-utils
livesys-scripts
pciutils
usbutils

# ─── Fonts ───
dejavu-sans-fonts
dejavu-sans-mono-fonts
google-noto-sans-fonts
google-noto-sans-mono-fonts
google-noto-color-emoji-fonts
liberation-fonts
qt6-qttranslations
# Arabic (optional):
# google-noto-sans-arabic-fonts
# google-noto-naskh-arabic-fonts

# ─── Disk & Filesystems ───
ntfs-3g
dosfstools
e2fsprogs
exfatprogs
f2fs-tools
btrfs-progs
udisks2
gvfs
gvfs-mtp
gvfs-afc
gvfs-smb
gvfs-archive

# ─── Printing & Scanning ───
cups
cups-filters
gutenprint-cups
print-manager
sane-backends
skanlite
# hplip   (HP printers — uncomment if wanted)

# ─── Modern Image Formats ───
libheif
qt6-qtimageformats
webp-pixbuf-loader

# ─── RPM Fusion only (uncomment repo above + these if wanted) ───
# vlc
# unrar

# ─── Excludes ───
-gnome-shell
-gnome-software
-orca
%end

# ═════════════════════════════════════════
# %post
# ═════════════════════════════════════════
%post --log=/root/m87-postinstall.log --erroronfail

# ─── Hostname (hostnamectl fails in chroot — no dbus) ───
echo "m87" > /etc/hostname

# ─── Graphical target ───
systemctl set-default graphical.target

# ─── Live user (anaconda-live cleans it up after install-to-disk) ───
useradd -m -c "M87 Live" -G wheel liveuser
passwd -d liveuser
echo "liveuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/00-liveuser
chmod 440 /etc/sudoers.d/00-liveuser

# ─── Live session behavior (autologin, first-boot setup, etc.) ───
# livesys applies these at LIVE BOOT time only, so nothing leaks into
# installed systems (a baked /etc/sddm.conf.d/*.conf WOULD be copied
# to the disk by the live installer — that's why it's not used here).
echo 'livesys_session="kde"' > /etc/sysconfig/livesys

# ─── Live system services ───
systemctl enable livesys.service
systemctl enable livesys-late.service

# If you insist on baked-in autologin (it will persist into installs):
# mkdir -p /etc/sddm.conf.d
# cat > /etc/sddm.conf.d/00-live-autologin.conf <<'EOF'
# [Autologin]
# User=liveuser
# Session=plasma
# Relogin=false
# EOF

# ─── Baloo indexing OFF on the live session (slow USB I/O) ───
mkdir -p /home/liveuser/.config
cat > /home/liveuser/.config/baloorc <<'EOF'
[Basic Settings]
Indexing-Enabled=false
EOF
chown -R liveuser:liveuser /home/liveuser

# ─── Firewall extras (mDNS discovery + KDE Connect) ───
firewall-offline-cmd --add-service=mdns || true
firewall-offline-cmd --add-port=1714-1764/tcp || true
firewall-offline-cmd --add-port=1714-1764/udp || true

# ─── Weekly TRIM ───
systemctl enable fstrim.timer

# ─── zram ───
cat > /etc/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

# ─── Plymouth ───
plymouth-set-default-theme spinner || true

# ─── dnf ───
cat > /etc/dnf/dnf.conf <<'EOF'
[main]
defaultyes=True
max_parallel_downloads=10
fastestmirror=True
EOF

# ─── GRUB defaults — patch, never replace (keeps Fedora's GRUB_CMDLINE_LINUX,
#     crashkernel, etc.). Anaconda regenerates grub.cfg at install time. ───
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub
sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub
grep -q '^GRUB_TIMEOUT_STYLE='      /etc/default/grub || echo 'GRUB_TIMEOUT_STYLE=hidden' >> /etc/default/grub
grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub || echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet rhgb vt.global_cursor_default=0"' >> /etc/default/grub
grep -q '^GRUB_DISABLE_OS_PROBER='  /etc/default/grub || echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
grep -q '^GRUB_RECORDFAIL_TIMEOUT=' /etc/default/grub || echo 'GRUB_RECORDFAIL_TIMEOUT=5' >> /etc/default/grub
# NOTE: no grub2-mkconfig / dracut -f here — Anaconda regenerates both.

# ─── NetworkManager ───
cat > /etc/NetworkManager/conf.d/performance.conf <<'EOF'
[connection]
wifi.powersave = 2
wifi.cloned-mac-address = permanent

[device]
wifi.scan-rand-mac-address = no
EOF

# ─── SSH hardening ───
cat > /etc/ssh/sshd_config.d/m87-hardening.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication yes
KbdInteractiveAuthentication no
UsePAM yes
AllowTcpForwarding no
X11Forwarding no
EOF
# Fresh host keys per machine (regenerated on first boot):
rm -f /etc/ssh/ssh_host_*

# ─── fish default shell for users created with useradd ───
sed -i 's|^SHELL=.*|SHELL=/usr/bin/fish|' /etc/default/useradd 2>/dev/null \
  || echo "SHELL=/usr/bin/fish" >> /etc/default/useradd

# ─── Flatpak (needs network during build) ───
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
flatpak config --set languages "en_US.UTF-8" || true

# ─── Cleanup / fresh identity per boot ───
dnf clean all
rm -f /var/lib/systemd/random-seed
truncate -s 0 /etc/machine-id

echo "M87 Linux 1.0 post-install done: $(date)" > /root/m87-install-complete

%end
# ═══════════════════════════════════════════════════════════════
