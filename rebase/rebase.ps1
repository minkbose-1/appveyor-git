# Download shallow repo
git remote add origin "https://github.com/${env:APPVEYOR_REPO_NAME}.git"
git fetch origin --no-tags --shallow-since=${REPO_MASTER_TIME}



# Remove CI commits
if( [int] $env:GIT_ERASE -Ne 0 ) {
  git checkout -f origin/${env:APPVEYOR_REPO_BRANCH}

  git reset --hard HEAD~${env:GIT_ERASE}

  git push -f origin HEAD:${env:APPVEYOR_REPO_BRANCH}
}



#################################################



curl -o "C:\repo.txt" "https://github.com/${env:APPVEYOR_REPO_NAME}"

$REPO_HTML = Get-Content "C:\repo.txt" -Raw



# Direct fork
$GIT_UPSTREAM = ( `
                  ($REPO_HTML -Split "forked from")[1] `
                  -Split "`">(.+)</a>" `
                )[1]


# Clone fork
if( $GIT_UPSTREAM -Eq $Null ) {
  $GIT_UPSTREAM = ( `
                    ($REPO_HTML -Split "<a title=")[1] `
                    -Split "`"https://github.com/(.+)`" role=`"link`""
                  )[1]
}


# Upstream repo
$GIT_DEFAULT = ( $REPO_HTML -Split "<span class=`"css-truncate-target`" data-menu-button>(.+)</span>" )[1]



#################################################



# Clone upstream repo
git remote add upstream "https://github.com/${GIT_UPSTREAM}.git"
git fetch upstream ${GIT_DEFAULT}:upstream --no-tags  --shallow-since=${REPO_MASTER_TIME} --quiet



# Prevent newline crlf fixes
Set-Content -Path ".git/info/attributes" -Value "* -text"



#################################################



$BRANCHES = git branch -r | Select-String -NotMatch "upstream"


foreach ($BRANCH in $BRANCHES) {
  $BRANCH = ( ($BRANCH -Replace '(^\s+|\s+$)','') -Split '/' )[1]
  echo "`n${BRANCH}"


  git checkout origin/${BRANCH} --force --quiet
  run_script "squash/squash.ps1"


  # Ignore orphan branches
  if ((git merge-base upstream/master origin/${BRANCH}) -Eq $Null) {
    continue
  }



  ### ================================================ ###



  git rebase upstream/${GIT_DEFAULT}



  if ($? -Eq $False) {
    git diff --diff-filter=U


    if ([string] ${env:GIT_FORCE} -Ne "yes") {
      throw "${BRANCH}: rebase failure"
    }


    git add .
    git commit --reuse-message=ORIG_HEAD
    git rebase --continue
  }



  ### ================================================ ###



  git push -f origin HEAD:${BRANCH}


  if( $? -Eq $False ) {
    throw "${BRANCH}: rebase failure"
  }
}



#################################################



echo "`n"
