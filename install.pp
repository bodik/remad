#!/usr/bin/puppet apply


# detect local kdc implementation
if( file_exists("/etc/krb5kdc/kadm5.acl") == 1 ) { 
	$kdc_impl = "mit" 
} elsif ( file_exists("/etc/heimdal-kdc/kadmind.acl") == 1 ) {
	$kdc_impl = "heimdal" 
}


# install
package { ["remctl-server"]: ensure => installed }
file { "/etc/remctl/conf.d/remadd":
	ensure => link, target => "/opt/remad/remadd-remctl-config",
	require => Package["remctl-server"],
}
file { "/opt/remad/remadd.conf":
	content => template("/opt/remad/remadd.conf.erb"),
	owner => "root", group => "root", mode => "0644",
}
file { "/etc/remadd.conf": ensure => link, target => "/opt/remad/remadd.conf", }


# kadmin acls for testbed
case $kdc_impl {
	"mit": {
		file_line { "main manager principal":
			path => "/etc/krb5kdc/kadm5.acl", line => "host/${fqdn} acdeilmps",
			notify => Service["krb5-admin-server"],
		}
		service { "krb5-admin-server": }
	}
	"heimdal": {
		file_line { "main manager principal":
			path => "/etc/heimdal-kdc/kadmind.acl", line => "host/${fqdn} cpw,list,delete,modify,add,get,get-keys",
		}
	}
}



# client
package { ["remctl-client"]: ensure => installed }
file { "/usr/local/bin/remad": ensure => link, target => "/opt/remad/remad", }

