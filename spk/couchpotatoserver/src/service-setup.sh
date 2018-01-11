PYTHON_DIR="/usr/local/python"
GIT_DIR="/usr/local/git"
PATH="${SYNOPKG_PKGDEST}/bin:${SYNOPKG_PKGDEST}/env/bin:${PYTHON_DIR}/bin:${GIT_DIR}/bin:${PATH}"
PYTHON="${SYNOPKG_PKGDEST}/env/bin/python"
VIRTUALENV="${PYTHON_DIR}/bin/virtualenv"
COUCHPOTATOSERVER="${SYNOPKG_PKGDEST}/share/CouchPotatoServer/CouchPotato.py"
CFG_FILE="${SYNOPKG_PKGDEST}/var/settings.conf"

GROUP="sc-download"

SERVICE_COMMAND="${PYTHON} ${COUCHPOTATOSERVER} --daemon --pid_file ${PID_FILE} --config_file ${CFG_FILE}"

service_postinst ()
{
    # Create a Python virtualenv
    ${VIRTUALENV} --system-site-packages ${SYNOPKG_PKGDEST}/env >> ${INST_LOG} 2>&1

    # Remove legacy user
    # Commands of busybox from spk/python
    delgroup "${USER}" "users" >> ${INST_LOG}
    deluser "${USER}" >> ${INST_LOG}
}