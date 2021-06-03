function global:run_script($File) {
  $y = ($File -Split "/*(.+)~")[1]
  $x = ($File -Split "/(.+)~")[1]

  echo $File

  if ($x -Ne $Null) {
    $File = $y + "/" + $x + ".ps1"
  }

  else if ($y -Ne $Null) {
    $File = $y + "/" + $y + ".ps1"
  }

  echo $File

  & "${APPVEYOR_GIT_FOLDER}/${File}"
}



###########################################



Invoke-WebRequest -Uri "https://github.com/${env:GIT_SCRIPT}/appveyor-git/archive/${GIT_SCRIPT_HEAD}.zip" -OutFile "${env:APPVEYOR_BUILD_FOLDER}/../appveyor-git.zip"
unzip "-DDqqo" "${env:APPVEYOR_BUILD_FOLDER}/../appveyor-git.zip" -d "${env:APPVEYOR_BUILD_FOLDER}/.."



$global:APPVEYOR_GIT_FOLDER = "${env:APPVEYOR_BUILD_FOLDER}/../appveyor-git-${GIT_SCRIPT_HEAD}"



#############################################



$env:PATH = ${env:APPVEYOR_BUILD_FOLDER} + ";" + ${env:PATH}



echo( `
  "`n`n" + `
  "CI image: ${env:APPVEYOR_BUILD_WORKER_IMAGE}`n" + `
  "`n`n" `
)



#############################################



$env:GIT_REDIRECT_STDERR = '2>&1'



if( (Test-Path -Path ".git") -Eq $False ) {
  git init --quiet


  echo "`n`n"
}



run_script "script/Invoke-Environment.ps1"



#############################################



$global:BRANCH_HEAD = git log --pretty=format:'%H' -1


run_script "login/login.ps1"



#############################################



$global:REPO_MASTER_HASH = $(git ls-remote "https://github.com/${env:APPVEYOR_REPO_NAME}" HEAD | `
                           awk '{ print $1 }')


git remote add repo_master "https://github.com/${env:APPVEYOR_REPO_NAME}.git"
git fetch repo_master $REPO_MASTER_HASH --depth=1 --no-tags --quiet


$global:REPO_MASTER_TIME = git log $REPO_MASTER_HASH -1 --format="%ci"
