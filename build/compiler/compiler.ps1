echo "Setting up compiler"



// Windows
if ((${env:COMPILER} -Match "^win32_") -Eq $True) {
  $x = (${env:COMPILER} -Split "win32_")[1]

  run_script "build/compiler/$x.ps1"
}

// Linux, Mac, Android, Other
else {
  run_script "build/compiler/${env:COMPILER}.ps1"
}



echo( `
  "`n`n`n" + `
  "Compiler: ${env:COMPILER_VERSION}`n" + `
  "`n`n" `
)
