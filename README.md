# build scripts for device images for UBports

These scripts are used by Jenkins build server to make daily builds of the device specific images for all devices supported by UBports project. For example the CI results for hammerhead are here: https://ci.ubports.com/job/daily-hammerhead

To test locally you can run the following commands (replace DEVICE with your devicename, ie, hammerhead, mako, ...)

```
git clone https://github.com/ubports/build-scripts
cd build-scripts
mkdir tmp
cd tmp
repo init -u https://github.com/ubports/android -b ubp-5.1 --depth=1
repo sync -j10 -c
mkdir .repo/local_manifests
cp ../devices.xml .repo/local_manifests/
../build.sh aosp_DEVICE-userdebug
# wait
rm -rf tar/
mkdir tar
../build-tarball.sh DEVICE tar/ overlay
ubuntu-device-flash touch --device=DEVICE --device-tarball=tar/device_DEVICE_devel.tar.xz --channel=ubports-touch/16.04/devel --bootstrap
```


