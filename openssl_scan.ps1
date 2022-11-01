# BEGIN CONFIG
# set to $true to scan all drives
$scan_all_drives = $false

# set the directory to search for OpenSSL libraries in (default: C:\)
# only needed if scanalldrives is $false !
$search_directory = "C:\"

# set to $true to show only OpenSSL version vulnerable to this bug
$only_vulnerable = $false
# END CONFIG

$confirm = Read-Host "This is an example script not meant for production use. To confirm that you understand and accept all responsibility, type: confirm"

if ($confirm -eq "confirm") {
    echo "starting scan"
    if ($only_vulnerable) {
	    $regex = "OpenSSL\s*3.0.[0-6]"
    }else{
	    $regex = "OpenSSL\s*[0-9].[0-9].[0-9]"
    }

    if ($scan_all_drives){
        $search_directory =  (Get-PSDrive -PSProvider FileSystem).Root
    }

    # search for any DLLs whose name begins with libcrypto
    Get-ChildItem -Path $search_directory -Include libcrypto*.dll,libssl*.dll,mod_ssl.so -File -Recurse -ErrorAction SilentlyContinue | Foreach-Object {
	    # use RegEx to parse the dll strings for an OpenSSL Version Number
	    $openssl_version = select-string -Path $_ -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value }
	    if ($openssl_version) {
		    # Print OpenSSL version number followed by file name
		    echo "$openssl_version - $_ "
	    }
    }
}else{
    echo "aborting"
}
