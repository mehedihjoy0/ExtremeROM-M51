#!/bin/sh

LOG "- Applying prop spoofer"
SECURITY_PATCH="$(getprop "ro.build.version.security_patch")"

cat >> "$WORK_DIR/system/system/etc/init/hw/init.rc" <<EOF

on property:service.bootanim.exit=1
    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.flash.locked 1
    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.vbmeta.device_state locked
    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.verifiedbootstate green
    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.veritymode enforcing
    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.warranty_bit 0
    exec u:r:init:s0 root root -- /system/bin/rezetprop -n sys.oem_unlock_allowed 0
    exec u:r:init:s0 root root -- /system/bin/settings put global ram_expand_size_list 0,1,2,4,6,8
    exec u:r:init:s0 root root -- /system/bin/device_config set_sync_disabled_for_tests persistent
    exec u:r:init:s0 root root -- /system/bin/device_config put activity_manager max_cached_processes 256
    exec u:r:init:s0 root root -- /system/bin/device_config put activity_manager max_phantom_processes 2147483647
    exec u:r:init:s0 root root -- /system/bin/settings put global settings_enable_monitor_phantom_procs false
    exec u:r:init:s0 root root -- /system/bin/device_config put activity_manager max_empty_time_millis 43200000
    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.vendor.build.security_patch "$SECURITY_PATCH"
EOF

sed -i 's/${ro.boot.warranty_bit}/0/g' "$WORK_DIR/system/system/etc/init/init.rilcommon.rc"

LINES="$(sed -n "/^(allow init init_exec\b/=" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil")"
for l in $LINES; do
sed -i "${l} s/)))/ execute_no_trans)))/" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
done
