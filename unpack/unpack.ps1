if (${env:GIT_CLEAN} -Eq "yes") {
  cd ${env:APPVEYOR_BUILD_FOLDER}

  move ${env:GIT_ARCHIVE} ..\
  move .git* ..\



  cd ..
  Remove-Item -Recurse -Force ${env:APPVEYOR_BUILD_FOLDER}
  New-Item -Path ${env:APPVEYOR_BUILD_FOLDER} -itemtype directory
  echo "6"



  move ${env:ARCHIVE $env:APPVEYOR_BUILD_FOLDER}
  echo "7"
  move .git* ${env:APPVEYOR_BUILD_FOLDER}
  echo "8"

  cd ${env:APPVEYOR_BUILD_FOLDER}
}



##########################################



7z x ${env:GIT_ARCHIVE} -aoa
del ${env:GIT_ARCHIVE}

git add .



##########################################



$title = git log -1 --pretty=format:'%s'


git reset --soft HEAD~1
git commit -m "$title"
