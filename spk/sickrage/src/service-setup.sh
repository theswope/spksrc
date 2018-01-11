PYTHON_DIR="/usr/local/python"
GIT_DIR="/usr/local/git"
PATH="${SYNOPKG_PKGDEST}/bin:${SYNOPKG_PKGDEST}/env/bin:${PYTHON_DIR}/bin:${GIT_DIR}/bin:${PATH}"
HOME="${SYNOPKG_PKGDEST}/var"
VIRTUALENV="${PYTHON_DIR}/bin/virtualenv"
GIT="${GIT_DIR}/bin/git"
PYTHON="${SYNOPKG_PKGDEST}/env/bin/python"
SICKRAGE="${SYNOPKG_PKGDEST}/var/SickRage/SiCKRAGE.py"
CFG_FILE="${SYNOPKG_PKGDEST}/var/config.ini"
UPGRADE_CFG_FILE="${TMP_DIR}/config.ini"

GROUP="sc-download"

SERVICE_COMMAND="${PYTHON} ${SICKRAGE} --daemon --pidfile ${PID_FILE} --config ${CFG_FILE} --datadir ${SYNOPKG_PKGDEST}/var/"

service_preinst ()
{
    # Check fork
    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ] && ! ${GIT} ls-remote --heads --exit-code ${wizard_fork_url:=https://git.sickrage.ca/sickrage/sickrage.git} ${wizard_fork_branch:=master} > /dev/null 2>&1; then
        echo "Incorrect fork"
        exit 1
    fi
}

service_postinst ()
{
    # Create a Python virtualenv
    ${VIRTUALENV} --system-site-packages ${SYNOPKG_PKGDEST}/env >> ${INST_LOG}

    # Clone the repository, install requirements and configure autoProcessTV
    ${GIT} clone --depth 10 --recursive -b ${wizard_fork_branch:=master} ${wizard_fork_url:=https://git.sickrage.ca/sickrage/sickrage.git} ${SYNOPKG_PKGDEST}/var/SickRage >> ${INST_LOG} 2>&1

    # PIP install requirements.txt
    if [ -f "${SYNOPKG_PKGDEST}/var/SickRage/requirements.txt" ]; then
        ${SYNOPKG_PKGDEST}/env/bin/pip install -U --build ${SYNOPKG_PKGDEST}/build --force-reinstall -r ${SYNOPKG_PKGDEST}/var/SickRage/requirements.txt >> ${INST_LOG} 2>&1
    fi

    # Copy scripts
    cp ${SYNOPKG_PKGDEST}/var/SickRage/sickrage/autoProcessTV/autoProcessTV.cfg.sample ${SYNOPKG_PKGDEST}/var/SickRage/sickrage/autoProcessTV/autoProcessTV.cfg
    chmod 777 ${SYNOPKG_PKGDEST}/var/SickRage/sickrage/autoProcessTV
    chmod 600 ${SYNOPKG_PKGDEST}/var/SickRage/sickrage/autoProcessTV/autoProcessTV.cfg

    # Remove legacy user
    # Commands of busybox from spk/python
    delgroup "${USER}" "users" >> ${INST_LOG}
    deluser "${USER}" >> ${INST_LOG}
}
