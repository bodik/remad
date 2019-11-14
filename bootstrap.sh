#!/bin/sh

if [ ! -d /opt/remad ]; then
	git clone https://gitlab.meta.zcu.cz/bodik/remad.git /opt/remad
	cd /opt/remad
	git remote set-url origin --push bodik@gitlab.meta.zcu.cz:bodik/remad.git
else
	cd /opt/remad
	git pull
fi