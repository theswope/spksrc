SPK_NAME = tmux
SPK_VERS = 2.6
SPK_REV = 4
SPK_ICON = src/tmux.png

DEPENDS = cross/$(SPK_NAME)

MAINTAINER = SynoCommunity
DESCRIPTION = tmux is a terminal multiplexer, it enables a number of terminals or windows to be accessed and controlled from a single terminal. tmux is intended to be a simple, modern, BSD-licensed alternative to programs such as GNU screen.
RELOAD_UI = no
DISPLAY_NAME = Tmux
STARTABLE = no
CHANGELOG = "1. Update to 2.6. 2) Added full DSM6 compatibility.

HOMEPAGE   = https://github.com/tmux/tmux/wiki
LICENSE    = BSD License

SERVICE_SETUP = src/service-setup.sh

POST_STRIP_TARGET = tmux_extra_install

include ../../mk/spksrc.spk.mk

.PHONY: tmux_extra_install
tmux_extra_install:
	install -m 755 src/tmux-utf8 $(STAGING_DIR)/bin/tmux-utf8
