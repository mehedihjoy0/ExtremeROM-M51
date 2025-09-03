LOG_STEP_IN "- Fixing up /product/etc/build.prop"
sed -i "/# Removed by /d" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/#bluetooth./bluetooth./g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/?=/=/g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "$(sed -n "/provisioning.hostname/=" "$WORK_DIR/product/etc/build.prop" | sed "2p;d")d" "$WORK_DIR/product/etc/build.prop"
LOG_STEP_OUT

LOG_STEP_IN "- Adding additional props"
BUILD_PROP="$WORK_DIR/system/system/build.prop"
VENDOR_PROP="$WORK_DIR/vendor/default.prop"

# Append properties into build.prop
cat >> "$BUILD_PROP" <<'EOF'

# ADDITIONAL PROPERTIES
####################################
profiler.force_disable_err_rpt=1
profiler.force_disable_ulog=1
logcat.live=disable
ro.ril.disable.power.collapse=1
pm.sleep_mode=1
windowsmgr.max_events_per_sec=60
wifi.supplicant_scan_interval=180
debug.force_low_ram=true
ro.config.small_battery=true

# Kernel & Debugging
ro.config.kernel=0
ro.config.alarm_alert=0
ro.config.ringtone=0
ro.config.notification_sound=0
ro.config.mms_sound=0
ro.config.cal_notification=0
ro.config.msg_notification=0
ro.kernel.logger=0
ro.kernel.android.checkjni=0
ro.kernel.checkjni=0

# Disable unnecessary services
ro.config.hw_fast_dormancy=1
ro.config.hw_power_saving=1
ro.config.hw_quickpoweron=true
ro.config.combined_signal=true
persist.sys.purgeable_assets=1
persist.sys.use_dithering=0
persist.sys.ui.hw=1
persist.sys.strictmode.visual=0
persist.sys.strictmode.disable=1

# Wi-Fi & Bluetooth Logging
wifi.supplicant_scan_interval=180
ro.ril.disable.power.collapse=1
pm.sleep_mode=1
ro.ril.power_collapse=1
persist.bluetooth.disableabsvol=true
persist.bluetooth.disableapm=true
persist.bluetooth.disableaptx=true
persist.bluetooth.enable_dual_mode_audio=false

# Samsung & Google Tracking
ro.smps.enable=false
ro.opa.eligible_device=false
ro.setupwizard.mode=DISABLED
ro.com.google.gmsversion=0
ro.com.google.clientidbase=android-samsung
ro.com.google.clientidbase.ms=android-samsung
ro.com.google.clientidbase.am=android-samsung
ro.com.google.clientidbase.yt=android-samsung
ro.com.google.clientidbase.gmm=android-samsung

# Samsung & Google Analytics
ro.sem.analytics.enable=false
ro.samsung.analytics.enable=false
ro.smps.enable=false
ro.error.receiver.default=com.samsung.errorreceiver
error.receiver.default=com.samsung.errorreceiver
ro.error.receiver.system.apps=com.samsung.errorreceiver
error.receiver.system.apps=com.samsung.errorreceiver
ro.config.tima=0
ro.config.timaversion=0
ro.fota.ops=no
ro.security.icd.flagmode=none
ro.security.mdpp.ux=Disabled
ro.security.vpnpp.ver=1.4
ro.security.vpnpp.release=5.0

# Disable debugging and logging
persist.debug.wfd.enable=0
persist.sys.debug.multi_window=0
debug.sf.hw=0
debug.egl.profiler=0
debug.egl.hw=0
debug.mdpcomp.logs=0
debug.enable.wl_log=0
debug.qualcomm.sns.daemon=0
debug.qualcomm.sns.hal=0
debug.qualcomm.sns.libsensor1=0
persist.service.lgospd.enable=0
persist.service.pcsync.enable=0
logcat.live=disable
ro.kernel.android.checkjni=0
ro.kernel.checkjni=0
dalvik.vm.checkjni=false
profiler.force_disable_err_rpt=1
profiler.force_disable_ulog=1
ro.config.htc.nocheckin=1
ro.config.nocheckin=1
ro.debuggable=0
persist.sys.usb.config=mtp
ro.secure=1
ro.adb.secure=1
ro.min_pointer_dur=8

# Fake Encryption
ro.crypto.state=encrypted
ro.boot.verifiedbootstate=green

# Fix Sheath
ro.security.keystore.keytype=gak,sgak

# Critical for SafetyNet's bootloader check
ro.boot.vbmeta.device_state=locked
ro.boot.verifiedbootstate=green
ro.boot.vbmeta.avb_version=1.0
ro.boot.vbmeta.hash_alg=sha256
ro.boot.flash.locked=1
ro.boot.veritymode=enforcing
ro.boot.enable_dm_verity=1

# Ensure enforcing mode
ro.build.selinux=1
persist.sys.selinux=enforce
ro.boot.selinux=enforcing

# Hide root/trigger Play Integrity
sys.usb.state=mtp,adb
ro.oem_unlock_supported=0

# Bypass hardware-backed attestation
ro.boot.vbmeta.digest=60b9255d6da193b8f7fc79b22b3f934c75fc21ef44735f8c3956be32e931c229
ro.boot.warranty_bit=0
ro.warranty_bit=0
ro.vendor.boot.warranty_bit=0
ro.vendor.warranty_bit=0

# Force basic attestation
persist.sys.phh.safetynet.hide=1
persist.sys.fflag.override.settings_hide_second_space=1
EOF

# Disable A2DP hardware offload in vendor
cat >> "$VENDOR_PROP" <<'EOF'

# Disable A2DP hardware offload
persist.bluetooth.a2dp_offload.disabled=true
persist.bluetooth.a2dp_offload.enable=false
persist.vendor.bluetooth.a2dp_offload.enable=false
ro.bluetooth.a2dp_offload.supported=false
persist.bluetooth.a2dp_offload.cap=
persist.vendor.bt.a2dp_offload_cap=
EOF
LOG_STEP_OUT