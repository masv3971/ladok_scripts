#!/usr/bin/env bash

script_name=$0
certificate_file=$1

print_usage() {
    printf "Usage %s <ladokcert.(p12||pfx)>\n" "${script_name}"
}

get_cert_key() {
    openssl pkcs12 -in "${1}" -nocerts -passin pass:"${2}" -password pass:"${2}" -passout pass:"${2}" -out "${3}".key
}

get_client_cert(){
    openssl pkcs12 -in "${1}" -passin pass:"${2}" -password pass:"${2}" -passout pass:"${2}" -out "${3}".crt -clcerts -nokeys
}

get_server_cert() {
    openssl pkcs12 -in "${1}" -passin pass:"${2}" -password pass:"${2}" -passout pass:"${2}" -out Ladok3.Chain.CA.pem -cacerts -nodes -nokeys
}

create_ladok_user() {
    curl -s --cert "${1}".crt:"${2}" --key "${1}".key https://"${3}"/kataloginformation/anvandare/autentiserad | xmllint -format -
}

choose_ladok_environment() {
    declare -A ladokEnvs
    ladokEnvs[Prod-API]=api.ladok.se
    ladokEnvs[Test-API]=api.test.ladok.se
    ladokEnvs[Int-test-API]=api.integrationstest.ladok.se

    for ou in "${!ladokEnvs[@]}"; do
        if openssl x509 -in "${1}".crt -passin pass:"${2}" -subject -noout | grep "${ou}"; then
            printf "\tenvironment is %s\n" "${ou}"
            ladok_environment=${ladokEnvs[${ou}]}
            return 0
        fi
    done
    return 1
}

if [[ -z "${certificate_file}" ]]; then
    print_usage
    exit
fi

certificate_name=${certificate_file::-4} # just the name of the certificate

printf "\nPlease enter password for cert:"
read -sr password_input

printf "\n\t** Handling cerfiticate **\n"

if [[ "${certificate_file}" =~ (p12$|pfx$) ]]; then
    printf "\tConvert cert bundle to x509 client certificate\n"

   if ! get_client_cert "${certificate_file}" "${password_input}" "${certificate_name}"; then
        printf "\tERROR can not convert cert bundle to client cert, exiting...\n"
        exit 1
    fi

    if ! get_cert_key "${certificate_file}" "${password_input}" "${certificate_name}"; then
        printf "\tERROR can not generate key, exiting...\n"
        exit 1
    fi

    if ! get_server_cert "${certificate_file}" "${password_input}"; then
        printf "\tERROR can not convert bunle to server cert, exiting...\n"
        exit 1
    fi
    printf "\tclient-cert, server-cert and key has been successfully created.\n"
fi

if ! choose_ladok_environment "${certificate_name}" "${password_input}"; then
    printf "\tERROR no ladok environment was found\n"
    exit 1
else 
    printf "\tLadok environment is %s\n" "${ladok_environment}"
fi

if ! create_ladok_user "${certificate_name}" "${password_input}" "${ladok_environment}"; then
    printf "\tERROR can not create ladok user\n"
    exit 1
fi