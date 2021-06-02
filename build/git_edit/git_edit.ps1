cd ${APPVEYOR_GIT_FOLDER}/build/git_edit



& ${env:CXX} git_edit.cpp -o git_edit.exe

$env:PATH = "$(Get-Location);" + $env:PATH



cd ${env:APPVEYOR_BUILD_FOLDER}
