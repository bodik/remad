#!/bin/sh

. /puppet/metalib/bin/lib.sh

SSHKEYSTORAGE="/var/ssh-key-storage"
TESTFILE_DST="/tmp/test_remad_getknownhosts_$$"

# setup
for key in "dsa" "rsa" "ecdsa" "ed25519"; do
	test -f "/tmp/test_remad_sshkey_${key}" || ssh-keygen -q -f "/tmp/test_remad_sshkey_${KEY}" -N '' -t ${key}
done
for i in $(seq 30 100); do
	DESTDIR="${SSHKEYSTORAGE}/ztook${i}.meta.zcu.cz"
	if [ ! -d "$DESTDIR" ]; then
		mkdir -p "${DESTDIR}"
		touch "$DESTDIR/selftest"

		for key in "dsa" "rsa" "ecdsa" "ed25519"; do
			cp /tmp/test_remad_sshkey_${key} ${DESTDIR}/ssh_host_${key}_key
			cp /tmp/test_remad_sshkey_${key}.pub ${DESTDIR}/ssh_host_${key}_key.pub
		done
	fi
done



# push
kinit -k -t /etc/krb5.keytab host/$(facter fqdn)
remad --debug getknownhosts --outfile ${TESTFILE_DST}
if [ $? -ne 0 ]; then
	rreturn 1 "remad failed"
fi


# test
LINES=$(wc -l ${TESTFILE_DST} | awk '{print $1}')
if [ $LINES -ne 84 ]; then # result 84 specifically crafted number for ztook testbed
	rreturn 1 "generated known_hosts not correct"
fi



rm -f ${TESTFILE_DST}
for i in $(seq 30 100); do
	DESTDIR="${SSHKEYSTORAGE}/ztook${i}.meta.zcu.cz"
	if [ -f "${DESTDIR}/selftest" ]; then
		rm -rf ${DESTDIR}
	fi
done
rreturn 0 "$0"
