# Download shallow repo
git remote add origin "https://github.com/${env:APPVEYOR_REPO_NAME}.git"
git fetch origin --no-tags --shallow-since=${REPO_MASTER_TIME}


# Prevent newline crlf fixes
Set-Content -Path ".git/info/attributes" -Value "* -text"


# Clone upstream repo
git remote add upstream "https://github.com/${env:GIT_UPSTREAM}.git"
git fetch upstream ${REPO_BRANCH}:upstream --depth=1 --quiet


git checkout origin/${env:GIT_BRANCH} --force --quiet
git rebase upstream/${REPO_BRANCH}
git push -f origin HEAD:${env:GIT_BRANCH}


# Shallow clone problem
if ($? -Eq $False) {
  echo "---  Full unshallow  ---"

  git fetch origin --no-tags --unshallow
  git push -f origin HEAD:${BRANCH}
}
