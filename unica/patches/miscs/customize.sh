MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)
REGION=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 2)
TARGET_FIRMWARE_PATH="$FW_DIR/$(echo -n "$TARGET_FIRMWARE" | sed 's./._.g' | rev | cut -d "_" -f2- | rev)"

# Set build ID
ROM_STATUS=""
$ROM_IS_OFFICIAL || ROM_STATUS=" UNOFFICIAL"
VALUE="$(GET_PROP "$WORK_DIR/system/system/build.prop" "ro.build.display.id")"
SET_PROP "system" "ro.build.display.id" "ExtremeROM$ROM_STATUS $ROM_CODENAME $ROM_VERSION - $TARGET_CODENAME ($VALUE)"

SET_PROP "system" "ro.extremerom.official" "$ROM_IS_OFFICIAL"
SET_PROP "system" "ro.extremerom.version" "$ROM_VERSION"
SET_PROP "system" "ro.extremerom.codename" "$ROM_CODENAME"

# Disable FRP
SET_PROP "vendor" "ro.frp.pst" ""
SET_PROP "product" "ro.frp.pst" ""

# Set Edge Lighting model
MODEL=$(echo "$TARGET_FIRMWARE" | sed -E 's/^([^/]+)\/.*/\1/')
SET_PROP "system" "ro.factory.model" "$MODEL"

# Fix portrait mode
if [[ -f "$TARGET_FIRMWARE_PATH/vendor/lib64/libDualCamBokehCapture.camera.samsung.so" ]]; then
    if grep -q "ro.build.flavor" "$TARGET_FIRMWARE_PATH/vendor/lib64/libDualCamBokehCapture.camera.samsung.so"; then
        SET_PROP "system" "ro.build.flavor" "$(GET_PROP "$TARGET_FIRMWARE_PATH/system/system/build.prop" "ro.build.flavor")"
    elif grep -q "ro.product.name" "$TARGET_FIRMWARE_PATH/vendor/lib64/libDualCamBokehCapture.camera.samsung.so"; then
        sed -i "s/ro.product.name/ro.unica.camera/g" "$WORK_DIR/vendor/lib/libDualCamBokehCapture.camera.samsung.so" && \
            sed -i "s/ro.product.name/ro.unica.camera/g" "$WORK_DIR/vendor/lib/liblivefocus_capture_engine.so" && \
            sed -i "s/ro.product.name/ro.unica.camera/g" "$WORK_DIR/vendor/lib/liblivefocus_preview_engine.so" && \
            sed -i "s/ro.product.name/ro.unica.camera/g" "$WORK_DIR/vendor/lib64/libDualCamBokehCapture.camera.samsung.so" && \
            sed -i "s/ro.product.name/ro.unica.camera/g" "$WORK_DIR/vendor/lib64/liblivefocus_capture_engine.so" && \
            sed -i "s/ro.product.name/ro.unica.camera/g" "$WORK_DIR/vendor/lib64/liblivefocus_preview_engine.so"
        echo -e "\nro.unica.camera u:object_r:build_prop:s0 exact string" >> "$WORK_DIR/system/system/etc/selinux/plat_property_contexts"
        SET_PROP "system" "ro.unica.camera" "$(GET_PROP "$TARGET_FIRMWARE_PATH/system/system/build.prop" "ro.product.system.name")"
    fi
fi

# Enable/Disable camera cutout protection
if [[ "$SOURCE_SUPPORT_CUTOUT_PROTECTION" != "$TARGET_SUPPORT_CUTOUT_PROTECTION" ]]; then
    if [[ "$TARGET_SINGLE_SYSTEM_IMAGE" == "qssi" ]]; then
        DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
        FTP="$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk/res/values/bools.xml"
        R="\ \ \ \ <bool name=\"config_enableDisplayCutoutProtection\">$TARGET_SUPPORT_CUTOUT_PROTECTION</bool>"
        sed -i "$(sed -n "/config_enableDisplayCutoutProtection/=" "$FTP") c$R" "$FTP"
    fi
fi
