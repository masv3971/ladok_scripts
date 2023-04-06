#!/usr/bin/env bash

cert="${1}"
key="${2}"

#echo ${cert} ${key}

call() {
    url=$1
    curl -S -s --cert "${cert}" --key "${key}" -v --header "Accept: application/vnd.ladok-kataloginformation+json" $url
}

behorighetsprofilURL=$(call "https://api.ladok.se/kataloginformation/anvandarbehorighet/egna" |jq '.Anvandarbehorighet[0].BehorighetsprofilRef.link.uri' |tr -d '"')

permissionProfile=$(call $behorighetsprofilURL| jq '.Systemaktiviteter[] | "\(.Id): \(.I18nNyckel)"')

printf "\n\n Ladok permission:\n ${permissionProfile}\n"