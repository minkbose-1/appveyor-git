cd ${APPVEYOR_GIT_FOLDER}/build



& ${env:CXX} git_edit.cpp -o git_edit.exe

$env:PATH = "$(Get-Location);" + $env:PATH



cd ${env:APPVEYOR_BUILD_FOLDER}
