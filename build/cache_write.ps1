if ($global:CACHE_WRITE -Ne $True) {
  return
}



cd ${env:APPVEYOR_BUILD_FOLDER}



#############################################



run_script "build/cache_time.ps1"



$CACHE_LIST = git ls-files --others --exclude-standard
$CACHE_LIST += git ls-files --modified --exclude-standard


echo "`n"
echo $CACHE_LIST


if ($CACHE_LIST -Eq $Null) {
  return
}



# Keep untracked new files
git reset $global:BRANCH_HEAD --quiet



# Use separate, non-rebase branch
git checkout --orphan ${env:APPVEYOR_REPO_BRANCH}_cache_temp --force --quiet


# Remove all project files
git reset



#############################################



echo "`n"
echo "Saving build progress`n"



7z a "cache.zip" "-tzip" "-mx=1" "-y" `
  "-ir!.\*.d" ` "-ir!.\*.o" `
  "-ir!.\*.obj" `
  > $Null

7z a "cache.zip" "-tzip" "-mx=1" "-y" `
  "-ir!.\*.exe" "-ir!.\*.dll" `
  "-ir!.\*.pdb" `
  > $Null

7z a "cache.zip" "-tzip" "-mx=1" "-y" "cache.hash" > $Null

git add "cache.zip"




git commit -m "build cache" --quiet



echo "`n`n"
git push -f origin "HEAD:${env:APPVEYOR_REPO_BRANCH}_cache"
