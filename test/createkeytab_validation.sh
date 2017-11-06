#!/bin/sh

. /puppet/metalib/bin/lib.sh

kinit -k -t /etc/krb5.keytab host/$(facter fqdn)

remad --debug createkeytab --host $(facter fqdn)~~~~ --services host --outfile /dev/null 2>&1 | grep 'invalid host'
if [ $? -ne 0 ]; then
	rreturn 1 "remadd is_valid_host failed"
fi

remad --debug createkeytab --host $(facter fqdn) --services host~~~~ --outfile /dev/null 2>&1 | grep 'invalid service' 
if [ $? -ne 0 ]; then
	rreturn 1 "remadd is_valid_service failed"
fi

rreturn 0 "$0"
