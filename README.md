# Ladok scripts

## ladok_generate_certificate_verify_user.sh

The original ide to this script comes from Klas Mattsson @ SU, thank you!

`$ ladok_generate_certificate_verify_user.sh <cert>.pfx`

create key, crt and pem files and verify the certificate against /kataloginformation/anvandare/autentiserad.

## get_permissions.sh
A simple way of checking ladok permissions for a client certificate

`get_permissons.sh <cert> <key>`

will print something like:
```
Ladok permission:
"41000: systemaktivitet.common.publik_feed"
"61001: systemaktivitet.studentinformation.lasa"
"11004: systemaktivitet.kataloginformation.las"
```