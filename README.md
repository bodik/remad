# remad

Authorization wrapper and kadmin interface for common admin tasks for nodes
deployment within metacentrum.cz and cerit.cz.

## installation

### client
```
git clone https://rsyslog.metacentrum.cz/remad.git /opt/remad
apt-get install remctl-client
ln -s /opt/remad/remad /usr/local/bin/remad
```

### server
see `install.pp` puppet recipe for installation hints

```
vim /etc/remadd.conf
/opt/remad/remadd conftest
```

## usage

### create keytab for a host
```
remad --server keyserver createkeytab --host $(facter fqdn) --service host nfs pbs ftp --outfile /etc/krb5.keytab
```

### upload key for a host
```
remad --server keyserver storesshhostkey --host $(facter fqdn) --filename /etc/ssh/ssh_host_rsa_key.pub
```

### retrieve key for a host
```
remad --server keyserver getsshhostkey --host $(facter fqdn) --filename ssh_host_rsa_key.pub --outfile /tmp/abc
```

### fetch current ssh_known_hosts file
```
remad --server keyserver getknownhosts --outfile /tmp/cde
```
