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
    openssl pkcs12 -in "${1}" -passin pass:"${2}" -password pass:"${2}" -passout pass:"${2}" -out "${3}".pem -cacerts -nodes -nokeys
}

decrypt_cert_key(){
    openssl rsa -in "${1}".key -out "${1}".key -passin pass:"${2}" -passout pass:"${2}"
}

cert_PEM_to_DER(){
    openssl x509 -inform PEM -in "${1}"."${2}" -outform DER -out "${1}"."${2}"
}

key_PEM_to_DER(){
    openssl rsa -inform PEM -in "${1}".key -outform DER -out "${1}".key
}



if [[ -z "${certificate_file}" ]]; then
    print_usage
    exit
fi
certificate_name=${certificate_file%.*} # just the name of the certificate
if [[ -z ${certificate_name} ]]; then
    printf "\tERROR can not get certificate_name, exiting..\n"
    exit 1
fi

printf "\nPlease enter password for cert:"
read -sr password_input

printf "\n\t** Handling cerfiticate **\n"

if [[ "${certificate_file}" =~ (p12$|pfx$) ]]; then
    printf "\tConvert cert bundle to x509 client certificate\n"

   if ! get_client_cert "${certificate_file}" "${password_input}" "${certificate_name}"; then
        printf "\tERROR can not convert cert bundle to client cert, exiting...\n"
        exit 1
    fi
    #if ! cert_PEM_to_DER "${certificate_name}" crt; then
    #    printf "\tERROR can not convert client cert from PEM to DER format\n"
    #    exit 1
    #fi

    if ! get_server_cert "${certificate_file}" "${password_input}" "${certificate_name}"; then
        printf "\tERROR can not convert bundle to server cert, exiting...\n"
        exit 1
    fi

    #if ! cert_PEM_to_DER "${certificate_name}" pem; then
    #    printf "\tERROR can not convert chain cert from PEM to DER format\n"
    #    exit 1
    #fi

    if ! get_cert_key "${certificate_file}" "${password_input}" "${certificate_name}"; then
        printf "\tERROR can not generate key, exiting...\n"
        exit 1
    fi

    if ! decrypt_cert_key "${certificate_name}" "${password_input}"; then
        printf "\tERROR can not decrypt privatekey, exiting...\n"
        exit 1
    fi

    #if ! key_PEM_to_DER "${certificate_name}"; then
    #    printf "\tERROR can not convert key from PEM to DER format \n"
    #    exit 1
    #fi

    printf "\tclient-cert and key has been successfully created.\n"
fi