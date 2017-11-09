#!/bin/sh

. /puppet/metalib/bin/lib.sh


kinit -k -t /etc/krb5.keytab host/$(facter fqdn)
remad --debug getsshhostkey --host $(facter fqdn) --filename test_remad_doesnotexist --outfile /dev/null
if [ $? -ne 1 ]; then
	rreturn 1 "remad doesnotexist test failed"
fi


rreturn 0 "$0"
