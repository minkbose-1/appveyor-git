$LAST_HASH = git log ${env:APPVEYOR_REPO_BRANCH} -1 --format="%H"



# Reset shallow state
git reset ${env:APPVEYOR_REPO_BRANCH} --hard
git fetch origin ${env:APPVEYOR_REPO_BRANCH} --depth=1 --no-tags --quiet



#############################################



do {
  git fetch origin ${env:APPVEYOR_REPO_BRANCH} --deepen=100 --no-tags --quiet


  $HASH_LIST = git log $LAST_HASH -100 --format="%H"


  ForEach( $LAST_HASH in $HASH_LIST ) {
    $LastTime = git log $LAST_HASH -1 --format="%ci"

    if( $LastTime -Le $REPO_MASTER_TIME ) {
      break
    }
  }
} while( $LastTime -Gt $REPO_MASTER_TIME )



#############################################



Set-Content -Path "${env:APPVEYOR_BUILD_FOLDER}/cache.hash" -Value $LAST_HASH -NoNewline
