PYTHON_DIR="/usr/local/python"
PATH="${SYNOPKG_PKGDEST}/bin:${SYNOPKG_PKGDEST}/env/bin:${PYTHON_DIR}/bin:${PATH}"
VIRTUALENV="${PYTHON_DIR}/bin/virtualenv"
PYTHON="${SYNOPKG_PKGDEST}/env/bin/python"
SABNZBD="${SYNOPKG_PKGDEST}/share/SABnzbd/SABnzbd.py"
CFG_FILE="${SYNOPKG_PKGDEST}/var/config.ini"
UPGRADE_CFG_FILE="${TMP_DIR}/config.ini"
LANGUAGE="env LANG=en_US.UTF-8"

GROUP="sc-download"

SERVICE_COMMAND="${LANGUAGE} ${PYTHON} ${SABNZBD} -f ${CFG_FILE} --pidfile ${PID_FILE} -d"

# Needed to force correct permissions, during update
# Extract the right paths from config file
if [ -r "${UPGRADE_CFG_FILE}" ]; then
    INCOMPLETE_FOLDER=`grep -Po '(?<=download_dir = ).*' ${UPGRADE_CFG_FILE}`
    COMPLETE_FOLDER=`grep -Po '(?<=complete_dir = ).*' ${UPGRADE_CFG_FILE}`
    WATCHED_FOLDER=`grep -Po '(?<=dirscan_dir = ).*' ${UPGRADE_CFG_FILE}`
    if [ -n "$(dirname "${INCOMPLETE_FOLDER}")" ]; then
        SHARE_PATH=$(dirname "${INCOMPLETE_FOLDER}")
    fi
fi

service_postinst ()
{
    # Create a Python virtualenv
    ${VIRTUALENV} --system-site-packages ${SYNOPKG_PKGDEST}/env >> ${INST_LOG}

    # Install wheels
    ${SYNOPKG_PKGDEST}/env/bin/pip install --no-deps --no-index -U --force-reinstall -f ${SYNOPKG_PKGDEST}/share/wheelhouse ${SYNOPKG_PKGDEST}/share/wheelhouse/*.whl >> ${INST_LOG}

    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
        # Edit the configuration according to the wizard
        sed -i -e "s|@download_dir@|${wizard_download_dir:=/volume1/downloads}|g" ${CFG_FILE}
    fi

    # Have to make sure our complete/incomplete dirs have right permissions
    if [ -n "${INCOMPLETE_FOLDER}" ] && [ -d "${INCOMPLETE_FOLDER}" ]; then
        set_syno_permissions "${INCOMPLETE_FOLDER}" "${GROUP}"
    fi
    if [ -n "${COMPLETE_FOLDER}" ] && [ -d "${COMPLETE_FOLDER}" ]; then
        set_syno_permissions "${COMPLETE_FOLDER}" "${GROUP}"
    fi
    if [ -n "${WATCHED_FOLDER}" ] && [ -d "${WATCHED_FOLDER}" ]; then
        set_syno_permissions "${WATCHED_FOLDER}" "${GROUP}"
    fi

    # Discard legacy obsolete busybox user account
    BIN=${SYNOPKG_PKGDEST}/bin
    $BIN/busybox --install $BIN >> ${INST_LOG}
    $BIN/delgroup "${USER}" "users" >> ${INST_LOG}
    $BIN/deluser "${USER}" >> ${INST_LOG}
}
