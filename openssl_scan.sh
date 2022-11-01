# BEGIN CONFIG
# set the directory to search for OpenSSL libraries in (default: /)
search_directory=/

# set to 1 to show only OpenSSL version vulnerable to this bug
only_vulnerable=0
#END CONFIG

echo This is an example script not meant for production use. To confirm that you understand and accept all responsibility, type: confirm
read confirm

if [[ "$confirm" == "confirm" ]]; then
    if [[ $only_vulnerable -eq 1 ]]; then
        regex="^OpenSSL\s*3.0.[0-6]"
    else
        regex="^OpenSSL\s*[0-9].[0-9].[0-9]"
    fi

    if ! command -v strings &> /dev/null
    then
        echo "strings could not be found, please install it and try again"
        exit
    fi

    for file_name in $(find $search_directory -type f -a \( -name 'libcrypto*.so*' -o -name 'libssl*.so*' -o -name 'libssl*.a*' -o -name 'libcrypto*.a*' -o -name mod_ssl.so -o -name openssl \)); do
        openssl_version=$( strings "$file_name" | grep -m1 "$regex")
        if [[ $openssl_version ]]; then
            echo  "$openssl_version" - "$file_name"
        fi
    done
else
    echo aborting
fi
