
service_prestart ()
{
    # Setup environment
    PATH="${SYNOPKG_PKGDEST}/bin:${PATH}"
    SYNCTHING="${SYNOPKG_PKGDEST}/bin/syncthing"
    CONFIG_DIR="${SYNOPKG_PKGDEST}/var"
    SYNCTHING_OPTIONS="-home=${CONFIG_DIR}"

    # Read additional startup options from /usr/local/syncthing/var/options.conf
    if [ -f ${CONFIG_DIR}/options.conf ]; then
        source ${CONFIG_DIR}/options.conf
    fi
    # Replace generic service startup, run service as daemon
    echo "Starting Syncthing as daemon under user ${EFF_USER} in group ${GRPN} with configuration directory ${CONFIG_DIR} and settings ${SYNCTHING_OPTIONS}" >> ${LOG_FILE}
    COMMAND="env HOME=${CONFIG_DIR} ${SYNCTHING} ${SYNCTHING_OPTIONS}"
    echo "${COMMAND}" >> ${LOG_FILE}

    if [ $SYNOPKG_DSM_VERSION_MAJOR -lt 6 ]; then
        su ${EFF_USER} -s /bin/sh -c "${COMMAND}" >> ${LOG_FILE} 2>&1 &
    else
        ${COMMAND} >> ${LOG_FILE} 2>&1 &
    fi
    echo "$!" > "${PID_FILE}"
}


service_postinst ()
{
    # Discard legacy obsolete busybox user account
    BIN=${SYNOPKG_PKGDEST}/bin
    $BIN/busybox --install $BIN >> ${INST_LOG}
    $BIN/delgroup "${USER}" "users" >> ${INST_LOG}
    $BIN/deluser "${USER}" >> ${INST_LOG}
}

