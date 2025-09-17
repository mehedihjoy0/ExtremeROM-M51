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
        curl -s --retry 5 --retry-delay 5 "https://24-samfw.cloud/v2/IxJCDiMnLh0eACEwHjE+JjwRMTk7CB4lFzssIDs2ByAzMUEgOzEUQDMQMCMBOyw/DwghHQk7CDk0LA0wMzAvORI7LDEDLCMkHiQgLS8XOTABODMDFwgfATUxKSwSLzQwLgAeGjMbQQUSMS87Mi8eAjsHLzEyESEDAQhCHQMlLxI4JDM5DTghICFABkIeCzwGHgM8FCMkNDEjCxVACTghHzInDQYuFx8rIwAvJCFAMxE8EQY5NRshDjURPho0ES8kNRYhOR44LwsJEQc5NBsjKyEAPg4hAAYsLjgeLDQRHg4yJTMsMiUNKzwAPh8mGzk5FyUzDTUHQQEuByADISxBIwMnOUANQAokMzYCICMXPjkDFzA1CS8pDTsxHhwzQAZCOzEHHjMsNCsNMT4eODAeHgkvIxQjAwcEODEvLxcHPgMBAwgGDSwpPDskKQgXOzQwOAAhKTw/FD01OCBCJgQwJjQnBzAzCDMDAywuAw02OR8vMEEHEgs8OQE4ITk1C0EpMgMuCyMDHhIjOAZCIwM0MAEWCCQjJDwwAQ0TEw==" -o "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip"
        
        echo "- Extracting firmware..."
        unzip -q "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip" -d "$ODIN_DIR/${MODEL}_${CSC}"
        rm -f "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip"
        
        touch "$ODIN_DIR/${MODEL}_${CSC}/.downloaded"
    elif [ "$i" == "$TARGET_FIRMWARE" ]; then
        # Special handling for source firmware - download from the specified URL
        mkdir -p "$ODIN_DIR/${MODEL}_${CSC}"
        echo "- Downloading target firmware from custom URL..."
        curl -s --retry 5 --retry-delay 5 "https://24-samfw.cloud/v2/IxJCDiMnLjANJCIdIychBA8vQQgzOx4lFzssIDs2ByAzMUEgOzEUQDMQMCMBOyw/LyUpQS8lLDA7JyE2CTssKRcWKSA0FiAeDTsKBjsEMAUXLEEkPAs0MSMWIQUNCyAhDy8+DSMRGkA1JQIWMhZBDTIWMy8XOCwzDS8pBC87BycvOx4lLzAvNTxABkIeCzwGHgM8FCMkNDEjCxVACTghHzInDQYuFx8rIwAvJCFAMxE8EQY5NRshDjURPho0ES8kNRYhOR44LwsJEQc5NBsjKyEAPg4hAAYsLjgeLDQRHg4yJTMsMiUNKzwAPh8mGzk5FyUzDTUHQQEuByADISxBIwMnOUANQAokMzYCICMXPjkDFzA1CS8pDTsxHhwzQAZCOzEHHjMsNCsNMT4eODAeHgk7MTAjAy8nODFBFwMwPh4eAwgwMywpPDskIQgXCDsxOAAhKTw/FD01OCBCJichGwkXIT0yFzNAFzsfJTsRKSsuLykXEjgCIQMXHxsSLD5ALgMzIzUxLgojOAZCIwM0MAEWCCQjJA0dHjkTEw==" -o "$ODIN_DIR/${MODEL}_${CSC}/firmware.zip"
        
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
