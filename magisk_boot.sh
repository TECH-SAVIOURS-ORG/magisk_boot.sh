#!/bin/bash

HOST_DIR="$HOME/magisk"
DEVICE_DIR="/sdcard/Android/data/org.lineageos.updater/files/LineageOS\ updates/"
DEVICE_DIR_noescape=/sdcard/Android/data/org.lineageos.updater/files/LineageOS\ updates/

# Check for lineage update/zip file
for file in $(adb shell ls $DEVICE_DIR)
do
    file=$(echo -e $file | tr -d "\r\n"); # EOL fix
    echo $file
done

# Get latest lineageos zip file and extract boot.img
if [[ `adb shell ls $DEVICE_DIR$file 2> /dev/null` ]]; then
    adb pull "$DEVICE_DIR_noescape/$file" $HOST_DIR/;
else
    echo "Zip file does not exist."
    read -p "Did you export the rom/zip file? If not got to Settings-System-Updater and run the script again."
exit
fi

# Get and push boot.img
cd $HOST_DIR
unzip lineage-18.1-*-nightly-*-signed.zip boot.img
adb push boot.img /sdcard/Download/

# Magisk boot.img patch and flash
read -p "Patch boot.img with magisk manually and press enter afterwards."
adb shell ls /sdcard/Download/magisk_patched-*.img | tr '\r' ' ' | xargs -n1 adb pull
adb reboot fastboot
fastboot flash boot magisk_patched-*.img
fastboot reboot

# Clean up
echo -n "Do you want to delete lineage-18.1-*-nightly-*-signed.zip, boot.img and magisk_patched file on your computer? (y/n)?"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    rm lineage-18.1-*-nightly-*-signed.zip
    rm boot.img
    rm magisk_patched-*.img
else
    echo "Ok. Keep it."
fi

echo -n "Do you want to delete LineageOS zip file on your phone. (y/n)? Check your device is fully loaded."
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    adb shell rm "/sdcard/Android/data/org.lineageos.updater/files/LineageOS\ updates/$file"
   echo "Delete magisk patched file manually in download folder."
else
    echo "Ok. Keep it."
fi

echo "That's it"
exit
