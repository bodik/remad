#!/bin/sh

. /puppet/metalib/bin/lib.sh

TESTFILE_SRC="/tmp/test_remad_storesshhostkey_maskdata_$$"
TESTFILE_DST="/var/ssh-key-storage/$(facter fqdn)/$(basename $TESTFILE_SRC)"
MESSAGE="REMADSECRET$$ MUST BE MASKED"
echo $MESSAGE > $TESTFILE_SRC


# push
kinit -k -t /etc/krb5.keytab host/$(facter fqdn)
remad --debug storesshhostkey --host $(facter fqdn) --filename $TESTFILE_SRC
if [ $? -ne 0 ]; then
	rreturn 1 "remad storesshhostkey failed"
fi

grep $(echo $MESSAGE | base64) /var/log/syslog 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
	rreturn 1 "data not masked"
fi



rm -f $TESTFILE_SRC $TESTFILE_DST
rreturn 0 "$0"
