$global:MERGE_DEPTH = 500



if( ${env:PROJECT} -Eq $Null ) {
  $env:PROJECT = ${env:APPVEYOR_PROJECT_NAME}
}


if( ${env:SOLUTION} -Eq $Null ) {
  $env:SOLUTION = "Makefile"
}



#####################################



$env:BUILD_PATH = Split-Path ${env:SOLUTION} -Parent


if( ${env:BUILD_PATH} -Eq $Null ) {
  $env:BUILD_PATH = "."
}


$env:SOLUTION = Split-Path ${env:SOLUTION} -Leaf



#####################################



cd ${env:APPVEYOR_BUILD_FOLDER}


if (Test-Path ".gitmodules") {
  git submodule update --init --recursive --depth 1

  echo "`n`n"
}


# After submodules, not before
${env:REMOTE_ORIGIN_FETCH} = git config remote.origin.fetch

git config --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"



#####################################



$global:REPO_DEFAULT_BRANCH = $(git ls-remote --symref https://github.com/${env:APPVEYOR_REPO_NAME} HEAD | `
                                awk -F"[:/\\t]*" '/ref/ { print $4 }')


$global:REPO_DEFAULT_HASH = $(git ls-remote "https://github.com/${env:APPVEYOR_REPO_NAME}" HEAD | `
                              awk '{ print $1 }')



git fetch origin $REPO_DEFAULT_HASH --depth=1 --no-tags --quiet


$global:REPO_DEFAULT_TIME = git log $REPO_DEFAULT_HASH -1 --format="%ci"


git fetch origin ${env:APPVEYOR_REPO_BRANCH} --shallow-since=$REPO_DEFAULT_TIME --quiet



#####################################



echo "Setting up compiler"


run_script "build/${env:COMPILER}.ps1"


echo( `
  "`n`n`n" + `
  "Compiler: ${env:COMPILER_VERSION}`n" + `
  "`n`n" `
)



#####################################



cd ${APPVEYOR_GIT_FOLDER}/build



& ${env:CXX} git_edit.cpp

$env:PATH = "$(Get-Location);" + $env:PATH



cd ${env:APPVEYOR_BUILD_FOLDER}



#####################################



function global:git_merge($branch) {
  git fetch origin ${branch} --shallow-since=$REPO_DEFAULT_TIME --quiet
  git merge origin/${branch} --quiet


  if( $LastExitCode -Ne 0 ) {
    git diff --diff-filter=U


    throw "${branch}: merge failed"
  }


  echo "`n"
}



#####################################



function global:git_modify($file, $mode) {
  Move-Item -Path ${file} -Destination ${file}___1
  git add . --force
  Move-Item -Path ${file}___1 -Destination ${file}


  git_edit.exe ${file} ${mode}
  git add . --force
  git commit -m "resolved"


  if( $LastExitCode -Ne 0 ) {
    git diff --diff-filter=U

    throw "${branch}: merge failed"
  }


  echo "`n"
}



#####################################



function global:git_resolve($branch, $file, $mode) {
  git fetch origin ${branch} --shallow-since=$REPO_DEFAULT_TIME --quiet
  git merge origin/${branch} --quiet


  git diff --diff-filter=U
  git_modify ${file} ${mode}


  echo "`n"
}
