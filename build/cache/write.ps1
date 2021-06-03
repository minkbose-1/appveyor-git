cd ${env:APPVEYOR_BUILD_FOLDER}



run_script "build/cache/cache_time.ps1"




echo "`n"
echo "Saving build progress`n"



7z a "cache.zip" "-tzip" "-mx=1" "-y" `
  "-ir!.\*.d" ` "-ir!.\*.o" `
  "-ir!.\*.exe" "-ir!.\*.dll" `
  "-ir!.\*.obj" `
  "-ir!.\*.pdb" "-ir!.\*.ipdb" "-ir!.\*.iobj" `
  > $Null

7z a "cache.zip" "-tzip" "-mx=1" "-y" "cache.hash" > $Null




# $CACHE_LIST = git ls-files --others --exclude-standard
# $CACHE_LIST += git ls-files --modified --exclude-standard


# echo "`n"
# echo $CACHE_LIST


if ($CACHE_LIST -Eq $Null) {
  # return
}



# Cache new files
git add -f cache.zip
git commit -m "cache" --quiet


# Keep untracked new files
# git reset $global:BRANCH_HEAD --quiet



#############################################



# Use separate, non-rebase branch
git checkout --orphan ${env:APPVEYOR_REPO_BRANCH}_cache_temp --force --quiet
git reset



# Override gitignore
git add -f "cache.zip"
git commit -m "CI: build cache" --quiet



echo "`n`n"
git push -f origin "HEAD:${env:APPVEYOR_REPO_BRANCH}_cache"
