#!/bin/sh

if [ ! -d /opt/remad ]; then
	cd /opt
	git clone https://rsyslog.metacentrum.cz/remad.git
else
	cd /opt/remad
	git remote set-url origin https://rsyslog.metacentrum.cz/remad.git
	git pull
fi

cd /opt/remad && git remote set-url origin bodik@rsyslog.metacentrum.cz:/data/remad.git
