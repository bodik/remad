# remctladm

Authorization wrapper and kadmin interface for some common admin tasks for
nodes deployment within metacentrum.cz and cerit.cz.

## installation

see install.pp puppet recipe for installation hints

## usage

### create keytab for a host

```
remad --server kdccesnet.ics.muni.cz createkeytab --host $(facter fqdn) --service host nfs pbs ftp --outfile /etc/krb5.keytab
```

