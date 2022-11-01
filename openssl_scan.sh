#!/usr/bin/env bash
set -uo pipefail

# BEGIN CONFIG
# set to 1 to show only OpenSSL version vulnerable to this bug
only_vulnerable=0
if [[ "$1" = '-o' ]]; then
    only_vulnerable=1
    shift
fi

# set the directory to search for OpenSSL libraries in (default: /)
search_directory="${1:-/}"
#END CONFIG

echo 'This is an example script not meant for production use. To confirm that you understand and accept all responsibility, type: confirm'
read -r confirm

if [[ "$confirm" == "confirm" ]]; then
    if (( only_vulnerable )); then
        regex='^OpenSSL\s*3\.0\.[0-6]'
    else
        regex='^OpenSSL\s*[0-9]\.[0-9]\.[0-9]'
    fi

    if ! command -v strings &> /dev/null; then
        echo "strings could not be found, please install it and try again"
        exit 1
    fi

    find "$search_directory" -type f '(' -name "libcrypto*.so*" -o -name "libssl*.so*" -o -name "libssl*.a*" -o -name "libcrypto*.a*" ')' | while read -r file_name; do
        strings -- "$file_name" | grep -e "$regex" | while read -r openssl_version; do
            echo "$openssl_version - $file_name"
        done
    done

    true
else
    echo aborting
    exit 1
fi
