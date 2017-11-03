#!/bin/sh

. /puppet/metalib/bin/lib.sh

TESTFILE1="/tmp/test_remad_validation"
TESTFILE2="/tmp/test_remad_validation~~~~"
dd if=/dev/urandom bs=100 count=1 2>/dev/null | sha256sum > $TESTFILE1
dd if=/dev/urandom bs=100 count=1 2>/dev/null | sha256sum > $TESTFILE2

kinit -k -t /etc/krb5.keytab host/$(facter fqdn)

remad --debug storesshhostkey --host $(facter fqdn)~~~~ --filename ${TESTFILE1} 2>&1 | grep 'invalid host'
if [ $? -ne 0 ]; then
	rreturn 1 "remadd is_valid_host failed"
fi

remad --debug storesshhostkey --host $(facter fqdn) --filename ${TESTFILE2} 2>&1 | grep 'invalid filename'
if [ $? -ne 0 ]; then
	rreturn 1 "remadd is_valid_filename failed"
fi

rm -f ${TESTFILE1} ${TESTFILE2}
rreturn 0 "$0"
