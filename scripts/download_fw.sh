#!/usr/bin/env bash
#
# Copyright (C) 2023 Salvo Giangreco
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# shellcheck disable=SC2162

set -e

# [
GET_LATEST_FIRMWARE()
{
    curl -s --retry 5 --retry-delay 5 "https://fota-cloud-dn.ospserver.net/firmware/$CSC/$MODEL/version.xml" \
        | grep latest | sed 's/^[^>]*>//' | sed 's/<.*//'
}

DOWNLOAD_FIRMWARE()
{
    local PDR
    PDR="$(pwd)"

    cd "$ODIN_DIR"
    if [ "$i" == "$SOURCE_FIRMWARE" ]; then
        # Special handling for source firmware - download from the specified URL
        mkdir -p "$ODIN_DIR/${MODEL}_${CSC}"
        echo "- Downloading source firmware from custom URL..."
        curl -s --retry 5 --retry-delay 5 "https://s05.ooo/v2/IxJCDiMnLiUDEQo/OwNBAzQkHjAXCB4lFzssIDs2ByAzMUEgOzEUQDMQMCMBOyw/MhcaJCMLQR8XEQckMiUhLTQsBwoDJAcGAwMzAhcIHj81GywhLiQVBhIXHgs0Ay4fNAMhOh4XIQYjOAcEPDAvPzQ4Ah04JCEjOwcsKTwvLAINQCw8PDAHOB4bBkIeCzwGHgM8FCMkNDEjCxVACTghHzInDQYuFx8rIwAvJCFAMxE8EQY5NRshDjURPho0ES8kNRYhOR44LwsJEQc5NBsjKyEAPg4hAAYsLjgeLDQRHg4yJTMsMiUNKzwAPh8mGzk5FyUzDTUHQQEuByADISxBIwMnOUANQAokMzYCICMXPjkDFzA1CS8pDTsxHhwzQAZCOzEHHjMsNCsNMT4eODAeHgkvIxQjAwcEODEvLxcHPgMBAwgGDSwpPDskKQgXOzYkOAAhKTw/FD01OCBCJhsjOTUnMR0JOykxIxc+Aw0XLw07NgZANAAdBgEWLx8eMS4DAzYULDsRHhsjOAZCIwM0ACMLDSQeCyIkAQ0TEw==" -o "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip"
        
        echo "- Extracting firmware..."
        unzip -q "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip" -d "$ODIN_DIR/${MODEL}_${CSC}"
        rm -f "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip"
        
        touch "$ODIN_DIR/${MODEL}_${CSC}/.downloaded"
    elif [ "$i" == "$TARGET_FIRMWARE" ]; then
        # Special handling for target firmware - download from the specified URL
        mkdir -p "$ODIN_DIR/${MODEL}_${CSC}"
        echo "- Downloading target firmware from custom URL..."
        curl -s --retry 5 --retry-delay 5 "https://s05.ooo/v2/IxJCDiMnND8hAzNAMy8FOTs7OT88Nh4lFzssIDs2ByAzMUEgOzEUJTMQMCMBOyw/FztBJCMwIEE1ABQkMiQvAzwkLj8PESwGLgApHjQWBwo1Ni4QHhYuLS42IToXFjQdMyQpMSMnITo0CAUkOxcGLBJAHjANJS87OwcvPTIRBhsNEQImHjY+MyYbOQAeCwgwHgs2JB4kDT8BFjQfLhEwGiEWBzA1AB0kITgeJS4nIRAyGyAKLhE+DDIABj8hOB4KHiUiMC4XIys8OCA5ND8UJTIAPiUyJy8wNAAvPzwAPisuJy8rLgQUCzIAMEImFiA1LgcgCjs2FDE7Bx4ROzYGIzIWLhYPCx4nEjYIBjJAIB4yLwofFwcgAw0xPhsmGwYDDTswJy8/FBYDMTAmOzExHwMDOwYeOyEmDSwhHDgxMTAjAy8nFwcpAx42MzwzAzMmIREHCwklAgI0GwZCMxsFOQEbIDAzABQwNBY0ORIsPiwuAAIgIwcuKzIlLDEDMCAdLwc+GjIANgYmGzkGHiQ8Px4WIzABAzQw" -o "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip"
        
        echo "- Extracting firmware..."
        unzip -q "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip" -d "$ODIN_DIR/${MODEL}_${CSC}"
        rm -f "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip"
        
        touch "$ODIN_DIR/${MODEL}_${CSC}/.downloaded"
    else
        # Original download method for other firmwares
        { samfirm -m "$MODEL" -r "$CSC" -i "$IMEI" > /dev/null; } 2>&1 \
            && touch "$ODIN_DIR/${MODEL}_${CSC}/.downloaded" \
            || exit 1
    fi
    
    [ -f "$ODIN_DIR/${MODEL}_${CSC}/.downloaded" ] && {
        echo -n "$(find "$ODIN_DIR/${MODEL}_${CSC}" -name "AP*" -exec basename {} \; | cut -d "_" -f 2)/"
        echo -n "$(find "$ODIN_DIR/${MODEL}_${CSC}" -name "CSC*" -exec basename {} \; | cut -d "_" -f 3)/"
        echo -n "$(find "$ODIN_DIR/${MODEL}_${CSC}" -name "CP*" -exec basename {} \; | cut -d "_" -f 2)"
    } >> "$ODIN_DIR/${MODEL}_${CSC}/.downloaded"

    echo ""
    cd "$PDR"
}

FIRMWARES=( "$SOURCE_FIRMWARE" "$TARGET_FIRMWARE" )
IFS=':' read -a SOURCE_EXTRA_FIRMWARES <<< "$SOURCE_EXTRA_FIRMWARES"
if [ "${#SOURCE_EXTRA_FIRMWARES[@]}" -ge 1 ]; then
    for i in "${SOURCE_EXTRA_FIRMWARES[@]}"
    do
        FIRMWARES+=( "$i" )
    done
fi
IFS=':' read -a TARGET_EXTRA_FIRMWARES <<< "$TARGET_EXTRA_FIRMWARES"
if [ "${#TARGET_EXTRA_FIRMWARES[@]}" -ge 1 ]; then
    for i in "${TARGET_EXTRA_FIRMWARES[@]}"
    do
        FIRMWARES+=( "$i" )
    done
fi
# ]

FORCE=false

while [ "$#" != 0 ]; do
    case "$1" in
        "-f" | "--force")
            FORCE=true
            ;;
        *)
            echo "Usage: download_fw [options]"
            echo " -f, --force : Force firmware download"
            exit 1
            ;;
    esac

    shift
done

mkdir -p "$ODIN_DIR"

for i in "${FIRMWARES[@]}"
do
    MODEL=$(echo -n "$i" | cut -d "/" -f 1)
    CSC=$(echo -n "$i" | cut -d "/" -f 2)
    IMEI=$(echo -n "$i" | cut -d "/" -f 3)

    if [ -f "$ODIN_DIR/${MODEL}_${CSC}/.downloaded" ]; then
        [ -z "$(GET_LATEST_FIRMWARE)" ] && continue
        if [[ "$(GET_LATEST_FIRMWARE)" != "$(cat "$ODIN_DIR/${MODEL}_${CSC}/.downloaded")" ]]; then
            if $FORCE; then
                echo "- Updating $MODEL firmware with $CSC CSC..."
                rm -rf "$ODIN_DIR/${MODEL}_${CSC}" && DOWNLOAD_FIRMWARE
            else
                echo    "- $MODEL firmware with $CSC CSC already downloaded"
                echo    "  A newer version of this device's firmware is available."
                echo -e "  To download, clean your Odin firmwares directory or run this cmd with \"--force\"\n"
                continue
            fi
        else
            echo -e "- $MODEL firmware with $CSC CSC already downloaded\n"
            continue
        fi
    else
        echo "- Downloading $MODEL firmware with $CSC CSC..."
        rm -rf "$ODIN_DIR/${MODEL}_${CSC}" && DOWNLOAD_FIRMWARE
    fi
done

exit 0
