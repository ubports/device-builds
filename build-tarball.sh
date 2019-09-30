set -ex

device=$1
output=$2
device_dir=$3
dir=out/target/product/$device

echo "Working on device: $device"
if [ ! -f "$dir/boot.img" ]; then
    echo "boot.img does not exist!"
exit 1; fi
if [ ! -f "$dir/recovery.img" ]; then
    echo "recovery.img does not exist!"
exit 1; fi
if [ ! -f "$dir/system.img" ]; then
    echo "system.img does not exist!"
exit 1; fi
wDir=$(mktemp -d /tmp/ota.XXXXXXXX)
mkdir $wDir/partitions
cp $dir/boot.img $wDir/partitions
cp $dir/recovery.img $wDir/partitions

## REMOVAL OF DEVICE_FILES
# Copy common device-files first so if there is some device spesific changes it will override the common ones
#cp -r device-files/common/* $wDir/
#cp -r device-files/$device/* $wDir/ || true

## This is the new overlay used for partitions, firmware, etc.
cp -r "$device_dir/ubuntu-overlay/*" $wDir/ || true

mkdir -p $wDir/system/var/lib/lxc/android/

## SPARSE FILE TRANSLATION
# Needed with Halium-7.1 builds mostly
fileType=$(file -b0 $dir/system.img)
if [[ $fileType == "Android sparse image"* ]]; then
    echo "Converting sparse image to image"
    mv $dir/system.img $dir/system.sparse.img
    simg2img $dir/system.sparse.img $dir/system.img
    e2fsck -fy $dir/system.img >/dev/null
    resize2fs -p -M $dir/system.img
fi

cp $dir/system.img $wDir/system/var/lib/lxc/android/
tar cfJ "$output/device_"$device"_devel.tar.xz" -C $wDir partitions/ system/
echo "$(date +%Y%m%d)-$RANDOM" > "$output/device_"$device"_devel.tar.build"
rm -r $wDir

