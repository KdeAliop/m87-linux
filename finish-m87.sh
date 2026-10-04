#!/bin/bash
set -e
W=/var/tmp/lmc-work-wg5cr_7t              # مجلد عمل هذا البناء
M=/var/tmp/lorax.imgutils.tqxfc85s        # نقطة تركيب هذا البناء
IMG=/home/kdealiop/iso-out/lmc-disk-98aoa9ja.img   # صورتك المخصصة
OUT=/home/kdealiop/iso-out/M87-Linux-1.0-x86_64.iso

echo "── [1/7] فحص بقايا العمل ──"
ls -lh "$W/images/" "$W/LiveOS/"
[ -f "$W/LiveOS/squashfs.img" ]        || { echo "❌ squashfs.img مفقود"; exit 1; }
[ -f "$W/images/eltorito.img" ]        || { echo "❌ eltorito.img مفقود"; exit 1; }
[ -f "$W/images/pxeboot/vmlinuz" ]     || { echo "❌ pxeboot/vmlinuz مفقود"; exit 1; }
[ -f "$W/images/pxeboot/initrd.img" ]  || { echo "❌ pxeboot/initrd.img مفقود"; exit 1; }

echo "── [2/7] ضمان تركيب الصورة ──"
if ! mountpoint -q "$M"; then
  mkdir -p "$M"
  mount -o ro,loop "$IMG" "$M"
fi
echo "الصورة مركّبة على $M ✅"

echo "── [3/7] مصدر ملفات EFI ──"
if [ -f "$M/boot/efi/EFI/fedora/shimx64.efi" ]; then
  SRC="$M/boot/efi/EFI/fedora"; echo "المصدر: داخل الصورة"
elif [ -f "/boot/efi/EFI/fedora/shimx64.efi" ]; then
  SRC="/boot/efi/EFI/fedora";   echo "المصدر: النظام المضيف"
else
  echo "❌ لا يوجد shimx64.efi"; exit 1
fi

echo "── [4/7] بناء EFI/BOOT ──"
rm -rf "$W/EFI/BOOT" "$W/EFI/fedora"
mkdir -p "$W/EFI/BOOT/fonts" "$W/EFI/fedora"
cp "$SRC/shimx64.efi" "$W/EFI/BOOT/BOOTX64.EFI"
cp "$SRC/shimx64.efi" "$W/EFI/BOOT/shimx64.efi"
cp "$SRC/grubx64.efi" "$W/EFI/BOOT/grubx64.efi"
cp /usr/share/grub/unicode.pf2 "$W/EFI/BOOT/fonts/" 2>/dev/null \
  || cp "$M/usr/share/grub/unicode.pf2" "$W/EFI/BOOT/fonts/"

cat > "$W/EFI/BOOT/grub.cfg" <<'GRUBCFG'
set timeout=5
set default=0
menuentry 'Start M87 Linux 1.0' --class fedora --class gnu-linux --class gnu --class os {
    linuxefi /images/pxeboot/vmlinuz root=live:CDLABEL=M87_1-0 rd.live.image quiet rhgb
    initrdefi /images/pxeboot/initrd.img
}
menuentry 'Start M87 Linux 1.0 (compat)' --class fedora --class gnu-linux --class gnu --class os {
    linux /images/pxeboot/vmlinuz root=live:CDLABEL=M87_1-0 rd.live.image quiet rhgb
    initrd /images/pxeboot/initrd.img
}
GRUBCFG
cp "$W/EFI/BOOT/grub.cfg" "$W/EFI/fedora/grub.cfg"

echo "── [5/7] إنشاء efiboot.img (ESP) ──"
rm -f "$W/images/efiboot.img"
dd if=/dev/zero of="$W/images/efiboot.img" bs=1M count=32 status=none
mkfs.vfat -n EFIBOOT "$W/images/efiboot.img" >/dev/null
mkdir -p /tmp/efimnt
mount -o loop "$W/images/efiboot.img" /tmp/efimnt
mkdir -p /tmp/efimnt/EFI/BOOT /tmp/efimnt/EFI/fedora
cp -a "$W/EFI/BOOT/." /tmp/efimnt/EFI/BOOT/
cp "$W/EFI/BOOT/grub.cfg" /tmp/efimnt/EFI/fedora/grub.cfg
umount /tmp/efimnt

echo "── [6/7] ختم الـ ISO ──"
xorrisofs -o "$W/images/boot.iso" -R -J -V M87_1-0 \
  --grub2-mbr "$M/usr/lib/grub/i386-pc/boot_hybrid.img" \
  -partition_offset 16 -appended_part_as_gpt \
  -append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B "$W/images/efiboot.img" \
  -iso_mbr_part_type EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 \
  -c boot.cat --boot-catalog-hide \
  -b images/eltorito.img -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot -e --interval:appended_partition_2:all:: -no-emul-boot \
  -graft-points \
  "images/pxeboot=$W/images/pxeboot" \
  "LiveOS=$W/LiveOS" \
  "LICENSE=$W/LICENSE" \
  "Fedora-Legal-README.txt=$W/Fedora-Legal-README.txt" \
  "boot/grub2=$W/boot/grub2" \
  "boot/grub2/i386-pc=$M/usr/lib/grub/i386-pc" \
  "images/eltorito.img=$W/images/eltorito.img" \
  "EFI/BOOT=$W/EFI/BOOT" \
  "EFI/fedora=$W/EFI/fedora"

echo "── [7/7] النقل النهائي ──"
[ -f "$OUT" ] && mv "$OUT" "${OUT%.iso}-prev-$(date +%H%M).iso" && echo "حفظت النسخة السابقة باسم -prev"
cp "$W/images/boot.iso" "$OUT"
ls -lh "$OUT"
echo "🎉 M87-Linux-1.0-x86_64.iso (المخصصة) جاهز!"
