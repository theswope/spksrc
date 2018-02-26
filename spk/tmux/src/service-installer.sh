service_postinst ()
{
    # Use the tmux-utf8-utf8 command for tmux-utf8
    ln -s ${SYNOPKG_PKGDEST}/bin/tmux-utf8 /usr/local/bin/tmux
}
