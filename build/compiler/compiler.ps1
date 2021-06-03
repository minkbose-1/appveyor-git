echo "Setting up compiler"



// Windows
if ((${env:COMPILER} -Match "^win32_") -Eq $False) {
  run_script "build/${env:COMPILER}.ps1"
}

// Linux, Mac, Android, Other
else {
  run_script "build/${env:COMPILER}.ps1"
}



echo( `
  "`n`n`n" + `
  "Compiler: ${env:COMPILER_VERSION}`n" + `
  "`n`n" `
)
