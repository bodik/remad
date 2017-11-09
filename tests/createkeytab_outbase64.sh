#!/bin/sh

. /puppet/metalib/bin/lib.sh

KEYTAB="/tmp/test_remad_createkeytab_$$"
for service in ftp pbs nfs; do
	if [ -f /etc/krb5kdc/kadm5.acl ]; then
		kadmin.local delprinc $service/$(facter fqdn) 1>/dev/null 2>/dev/null
	fi
	if [ -f /etc/heimdal-kdc/kadmind.acl ]; then
		kadmin.heimdal -l delete $service/$(facter fqdn) 1>/dev/null 2>/dev/null
	fi
done

# create
kinit -k -t /etc/krb5.keytab host/$(facter fqdn)
remad --debug createkeytab --host $(facter fqdn) --services ftp pbs nfs --outfile - --outbase64 | base64 -d > ${KEYTAB}
if [ $? -ne 0 ]; then
	rreturn 1 "remad failed"
fi

# test
for service in ftp pbs nfs; do
	kinit -k -t ${KEYTAB} ${service}/$(facter fqdn) || rreturn 1 "$0 kinit $service failed"
done


rm -f ${KEYTAB}
rreturn 0 "$0"
