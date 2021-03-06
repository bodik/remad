# remad

Authorization wrapper and kadmin interface for common admin tasks for nodes
deployment within metacentrum.cz and cerit.cz.

## installation

### client
```
git clone https://gitlab.meta.zcu.cz/bodik/remad.git /opt/remad
apt-get install remctl-client || yum install remctl.x86_64
ln -s /opt/remad/remad /usr/local/bin/remad
```

### server
see `install.pp` puppet recipe for installation hints

```
vim /etc/remadd.conf
/opt/remad/remadd conftest
```

## standard usage

### create keytab for a host
```
remad --server keyserver createkeytab \
	--host $(facter fqdn)[@REALM] \
	--service host nfs pbs ftp \
	--outfile /etc/krb5.keytab
```

### force rekey for a host
```
remad --server keyserver createkeytab \
	--host $(facter fqdn)[@REALM] \
	--service host nfs pbs ftp \
	--outfile /etc/krb5.keytab \
	--rekey
```

### upload key for a host
```
remad --server keyserver storesshhostkey \
	--host $(facter fqdn)[@REALM] \
	--filename /etc/ssh/ssh_host_rsa_key.pub
```

### retrieve key for a host
```
remad --server keyserver getsshhostkey \
	--host $(facter fqdn)[@REALM] \
	--filename ssh_host_rsa_key.pub \
	--outfile /tmp/abc
```

### fetch current ssh_known_hosts file
```
remad --server keyserver getknownhosts --outfile /tmp/cde
```

## special cases

### pipe created keytab to stdout encoded in base64
```
remad --server keyserver createkeytab \
	--host $(facter fqdn)[@REALM] \
	--service host nfs pbs ftp \
	--outfile - \
	--outbase64
```

### upload key for a host from stdin
```
cat /etc/ssh/ssh_host_rsa_key.pub | remad --server keyserver storesshhostkey \
	--host $(facter fqdn)[@REALM] \
	--filename ssh_host_rsa_key.pub \
	--stdin
```
