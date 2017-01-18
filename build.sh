set -e

device=$1

export USE_CCACHE=1
repo sync -j10 -c --force-sync
source build/envsetup.sh
lunch $device
time make clobber
time make -j10
