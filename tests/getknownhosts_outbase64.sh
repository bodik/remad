#!/bin/sh

. /puppet/metalib/bin/lib.sh

SSHKEYSTORAGE="/var/ssh-key-storage"
TESTFILE_DST="/tmp/test_remad_getknownhosts_$$"

# setup
for key in "dsa" "rsa" "ecdsa" "ed25519"; do
	test -f "/tmp/test_remad_sshkey_${key}" || ssh-keygen -q -f "/tmp/test_remad_sshkey_${key}" -N '' -t ${key}
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

# artificial testcases
DESTDIR="${SSHKEYSTORAGE}/ztook29.meta.zcu.cz"
if [ ! -d "$DESTDIR" ]; then
	mkdir -p "${DESTDIR}"
	touch "$DESTDIR/selftest"

	echo "somedata" > ${DESTDIR}/ssh_host_dsa_key
	echo "typestr" > ${DESTDIR}/ssh_host_dsa_key.pub

	echo "somedata" > ${DESTDIR}/ssh_host_rsa_key
	echo "typestr1 keydata1" > ${DESTDIR}/ssh_host_rsa_key.pub

	echo "somedata" > ${DESTDIR}/ssh_host_ecdsa_key
	echo "typestr2 keydata2 keyalias2" > ${DESTDIR}/ssh_host_ecdsa_key.pub
fi






kinit -k -t /etc/krb5.keytab host/$(facter fqdn)
remad --debug getknownhosts --outfile - --outbase64 | base64 -d > ${TESTFILE_DST}
if [ $? -ne 0 ]; then
	rreturn 1 "remad failed"
fi






egrep 'ztook29,ztook29.meta.zcu.cz,ztook29.metacentrum.cz,[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ typestr1 keydata1' ${TESTFILE_DST}
if [ $? -ne 0 ]; then
	rreturn 1 "known_hosts missing lines"
fi

LINES=$(wc -l ${TESTFILE_DST} | awk '{print $1}')
if [ $LINES -ne 86 ]; then # result 86 specifically crafted number for ztook testbed
	rreturn 1 "generated known_hosts not correct"
fi


rm -f ${TESTFILE_DST}
for i in $(find ${SSHKEYSTORAGE} -type f -name "selftest"); do
	rm -rf $(dirname $i)
done
rreturn 0 "$0"
