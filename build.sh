set -e

device=$1

export USE_CCACHE=1
repo sync -c --force-sync

if [ -d "hybris-patches" ]; then
    hybris-patches/apply-patches.sh --mb
fi

source build/envsetup.sh
lunch $device
time make clobber
time make -j10
