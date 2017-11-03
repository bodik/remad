#!/bin/sh

. /puppet/metalib/bin/lib.sh

TESTFILE="test_remad_validation~~~~"

kinit -k -t /etc/krb5.keytab host/$(facter fqdn)

remad --debug getsshhostkey --host $(facter fqdn)~~~~ --filename validfilename --outfile /dev/null 2>&1 | grep 'invalid host'
if [ $? -ne 0 ]; then
	rreturn 1 "remadd is_valid_host failed"
fi

remad --debug getsshhostkey --host $(facter fqdn) --filename ${TESTFILE} --outfile /dev/null 2>&1 | grep 'invalid filename'
if [ $? -ne 0 ]; then
	rreturn 1 "remadd is_valid_filename failed"
fi

rreturn 0 "$0"
