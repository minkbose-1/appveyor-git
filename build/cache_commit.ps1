# Save all changes
cd ${env:APPVEYOR_BUILD_FOLDER}

git add . -A
git commit -m "cache temp" --quiet



# Makefile path
cd ${env:APPVEYOR_BUILD_FOLDER}/${env:BUILD_PATH}



# Status
$global:CACHE_WRITE = $True
