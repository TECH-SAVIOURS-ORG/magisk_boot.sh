#!/bin/bash

HOST_DIR="$HOME/magisk"
#DEVICE_DIR="/sdcard/Android/data/org.lineageos.updater/files/LineageOS\ updates/"
DEVICE_DIR="/sdcard/Download"
LINEAGE="lineage-*-signed.zip"

if [ ! -d $HOST_DIR ]; then
  mkdir -p $HOST_DIR;
fi

for file in $(adb shell ls $DEVICE_DIR/$LINEAGE)
do
    file=$(echo -e $file | xargs -n 1 basename);
done

# Get latest lineageos zip file
if adb shell ls $DEVICE_DIR/$LINEAGE ; then
    adb pull $DEVICE_DIR/$file $HOST_DIR/;
else
    echo "Zip file does not exist.
Did you export the rom/zip file? If not got to Settings-System-Updater and run the script again."
exit
fi

# Get and push boot.img
cd $HOST_DIR
unzip $file boot.img
adb push boot.img /sdcard/Download/

# Magisk boot.img patch and flash
read -p "Patch boot.img with magisk manually and press enter afterwards."
adb shell ls /sdcard/Download/magisk_patched-*.img | tr '\r' ' ' | xargs -n1 adb pull
adb reboot fastboot
fastboot flash boot magisk_patched-*.img
fastboot reboot

# Clean up
echo -n "Do you want to delete $file, boot.img and magisk_patched file on your computer? (y/n)"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    rm $file
    rm boot.img
    rm magisk_patched-*.img
else
    echo "Ok, keep it. But remember to delete it before you run the script again. It may cause problems if the wrong patch is being flashed. E.g. bootloop. Just moved in a backup folder."
fi

echo -n "Do you want to delete $file, boot.img and magisk_patched file on your phone? (y/n) - Check your device is fully loaded."
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    adb shell rm $DEVICE_DIR/$file
    adb shell rm $DEVICE_DIR/boot.img
    adb shell rm $DEVICE_DIR/magisk_patched-*.img   
else
    echo "Ok, keep it. But remember to delete it before you run the script again. It may cause problems if the wrong patch is being flashed. E.g. bootloop. Just moved in a backup folder."
fi

echo -n "Do you want to delete $HOST_DIR? (y/n)?"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    rm -r $HOST_DIR  
else
    echo "Kept $HOST_DIR."
fi

echo "That's it"
exit
