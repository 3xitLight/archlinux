#!/bin/bash

PS3='Please choose a Toolchain: '
options=("GOOGLE-aarch64-linux-android-4.9" "LINARO-aarch64-linux-gnu" "UBERTC-aarch64-linux-android-4.9" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "GOOGLE-aarch64-linux-android-4.9")
            echo "you chose choice 1"
            ;;
        "LINARO-aarch64-linux-gnu")
            echo "you chose choice 2"
            ;;
        "UBERTC-aarch64-linux")
            echo "you chose choice $REPLY which is $opt"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
