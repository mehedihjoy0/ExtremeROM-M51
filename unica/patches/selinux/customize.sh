# UN1CA SELinux entries removal list
# - Append new type entries to the ENTRIES list
# - Add the EXACT type entry, DO NOT just add a common pattern (eg. "fabriccrypto", "fabriccrypto_exec" and NOT just "fabriccrypto")
# - DO NOT add the API version at the end of the entry (eg. "fabriccrypto" and NOT "fabriccrypto_30_0")
# - DO NOT add add any parenthesis or statements (eg. "fabriccrypto" and NOT "expanttypeattribute ... (fabriccrypto)")
# - DO NOT add unnecessary types or remove the existing ones unless they aren't necessary anymore for all devices

# One UI 7.0 additions
ENTRIES="
attiqi_app
attiqi_app_data_file
ker_app
kpp_app
kpp_data_file
"

# One UI 6.1.1 additions
ENTRIES+="
hal_dsms_default
hal_dsms_default_exec
proc_compaction_proactiveness
sbauth
sbauth_exec
"

# One UI 5.1.1 additions
ENTRIES+="
audiomirroring
audiomirroring_exec
audiomirroring_service
fabriccrypto
fabriccrypto_exec
fabriccrypto_data_file
hal_dsms_service
uwb_regulation_skip_prop
"

# Galaxy M51 unsupported additions
ENTRIES+="
CustomFrequencyManager_service
DMM-daemon
DMM-daemon_exec
FlexibleLog
FlexibleLog_exec
IPSecService
IPSecService_exec
SemInputDeviceManager_service
aidl_codecsolution_service
apex_appsearch_data_file
debug_level_prop
diagexe
diagexe_exec
e4defrag_exec
exported_radio_prop
exported_wifi_prop
ikev2_client_exec
media_rw_data_file
nfc_ese_prop
perf_prop
proc_compaction_proactiveness
qsguard_33_0
qsguard_34_0
sec-ril
sec-ril_exec
sec-sh
sec-sh_exec
sec_diag
sec_diag_exec
sec_hdr_prop
spengesture_service
tee_service
teeregistry_service
trustonicpartner_app
vendor_afp_prop_33_0
vendor_afp_prop_34_0
vendor_hal_displayconfig_service
vendor_hal_qvirt_service
vendor_hal_qvirtservice_qti
vendor_hal_systemhelper_hwservice
vendor_hal_telephony_service
vendor_mm_parser_prop
vendor_persist_rcs_prop
vendor_persist_tcm_prop
vendor_qcc_authmgr_app
vendor_qcc_lmtp_app
vendor_qcc_netstat_app
vendor_qesdk_service
vendor_qesdk_service_new
vendor_qvirtmgr
vendor_smcinvoke_device
vendor_systemhelper_app
vendor_wlc_public_prop
wlbtlog_prop
"

# [
GET_SYSTEM_EXT()
{
    if $TARGET_HAS_SYSTEM_EXT; then
        echo "system_ext"
    else
        echo "system/system/system_ext"
    fi
}

CIL_NAME="$(head -n 1 "$WORK_DIR/vendor/etc/selinux/plat_sepolicy_vers.txt")"

VENDOR_API_LIST="$(find "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping" -type f -printf "%f\n" | \
                    sed '/.compat./d' | sed 's/.cil//' | sed 's/\./_/' | sort)"
# ]

for e in $ENTRIES; do
    if grep -q -F "($e)" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil" || \
         grep -q -F "${e}_${CIL_NAME//./_}" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil"; then
        # the problematic entry is currently present in system_ext, check if we need to remove it
        if ! grep -q -F "(type $e)" "$WORK_DIR/vendor/etc/selinux/plat_pub_versioned.cil"; then
            # the problematic entry is not supported by the target device
            LOG "- \"$e\" SELinux entry not supported. Removing"
            sed -i "/($e)/d" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil"
            for a in $VENDOR_API_LIST; do
                sed -i "/${e}_${a}/d" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil"
            done
            if grep -q "genfscon.*$e" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/system_ext_sepolicy.cil"; then
                sed -i "/genfscon.*$e/d" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/system_ext_sepolicy.cil"
            fi
            if grep -q "genfscon.*$e" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"; then
                sed -i "/genfscon.*$e/d" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
            fi
        fi
    fi
done
