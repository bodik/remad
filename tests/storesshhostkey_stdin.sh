#!/bin/sh

. /puppet/metalib/bin/lib.sh

TESTFILE_SRC="/tmp/test_remad_storesshhostkey_$$"
TESTFILE_DST="/var/ssh-key-storage/$(facter fqdn)/$(basename $TESTFILE_SRC)"
dd if=/dev/urandom bs=100 count=1 2>/dev/null | sha256sum > $TESTFILE_SRC



# push
kinit -k -t /etc/krb5.keytab host/$(facter fqdn)
cat $TESTFILE_SRC | remad --debug storesshhostkey --host $(facter fqdn) --filename $(basename ${TESTFILE_SRC}) --stdin
if [ $? -ne 0 ]; then
	rreturn 1 "remad failed"
fi



# test
diff -rua $TESTFILE_SRC $TESTFILE_DST
if [ $? -ne 0 ]; then
	rreturn 1 "stored file differs"
fi



rm -f $TESTFILE_SRC $TESTFILE_DST
rreturn 0 "$0"
