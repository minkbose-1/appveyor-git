$LAST_HASH = git log ${env:APPVEYOR_REPO_BRANCH} -1 --format="%H"



#############################################



do {
  git fetch origin ${env:APPVEYOR_REPO_BRANCH} --deepen=25 --no-tags --quiet


  $HASH_LIST = git log $LAST_HASH -25 --format="%H"


  ForEach( $LAST_HASH in $HASH_LIST ) {
    $LastTime = git log $LAST_HASH -1 --format="%ci"

    if( $LastTime -Le $REPO_MASTER_TIME ) {
      break
    }
  }
} while( $LastTime -Gt $REPO_MASTER_TIME )



#############################################



Set-Content -Path "${env:APPVEYOR_BUILD_FOLDER}/cache.hash" -Value $LAST_HASH -NoNewline
