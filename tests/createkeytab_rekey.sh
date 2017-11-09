#!/bin/sh

. /puppet/metalib/bin/lib.sh

getkvno() {
	KEYTAB="$1"
	PRINCIPAL="$2"

	if [ -f /etc/krb5kdc/kadm5.acl ]; then
		echo "$(klist -k ${KEYTAB} | grep ${service}/$(facter fqdn) | head -n1 | awk '{print $1}')"
		return
	fi

	if [ -f /etc/heimdal-kdc/kadmind.acl ]; then
		echo "$(ktutil -k ${KEYTAB} list | grep ${service}/$(facter fqdn) | head -n1 | awk '{print $1}')"
		return
	fi

	echo "error"
	return
}



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
remad --debug createkeytab --host $(facter fqdn) --services ftp pbs nfs --outfile ${KEYTAB}
if [ $? -ne 0 ]; then
	rreturn 1 "remad failed"
fi

for service in ftp pbs nfs; do
	kinit -k -t ${KEYTAB} ${service}/$(facter fqdn) || rreturn 1 "$0 kinit $service failed"
done

for service in ftp pbs nfs; do
	KVNO=$(getkvno ${KEYTAB} ${service}/$(facter fqdn))
	if [ "$KVNO" != "1" ]; then
		rreturn 1 "wrong upserted kvno"
	fi
done

rm ${KEYTAB}



# rekey
kinit -k -t /etc/krb5.keytab host/$(facter fqdn)
remad --debug createkeytab --host $(facter fqdn) --services ftp pbs nfs --outfile ${KEYTAB} --rekey
if [ $? -ne 0 ]; then
	rreturn 1 "remad failed"
fi

for service in ftp pbs nfs; do
	kinit -k -t ${KEYTAB} ${service}/$(facter fqdn) || rreturn 1 "$0 kinit $service failed"
done

for service in ftp pbs nfs; do
	KVNO=$(getkvno ${KEYTAB} ${service}/$(facter fqdn))
	if [ "$KVNO" != "2" ]; then
		rreturn 1 "wrong upserted kvno"
	fi
done

rm ${KEYTAB}

rreturn 0 "$0"
