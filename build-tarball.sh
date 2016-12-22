set -e

device=$1
output=$2
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
cp -r device-files/$device/* $wDir/
mkdir -p $wDir/system/var/lib/lxc/android/
cp $dir/system.img $wDir/system/var/lib/lxc/android/
tar cfJ "$output/device_"$device"_devel.tar.xz" -C $wDir partitions/ system/
echo "$(date +%Y%m%d)-$RANDOM" > "$output/device_"$device"_devel.tar.build"
rm -r $wDir

