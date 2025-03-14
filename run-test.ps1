[CmdletBinding()]
param (
     [Parameter()]
     [switch]
     $clear = $false,
     [switch]
     $help = $false,
     [switch]
     $testall = $false,
     [string]
     $runtest = "",
     [switch]
     $gui = $false # TODO
)

$need_runtest = $false

if ($runtest -ne "") {
     $testall = $false
     $need_runtest = $true
}

if ($help) {

     Write-Output "Usage:"
     Write-Output "      -clear         -    clears './test/*' folder"
     Write-Output "      -help          -    outputs help message"
     Write-Output "      -testall       -    run all verifications and produce .VVP"
     Write-Output "      -gui           -    if corresponding test is running, open it in gtkwave"
     #Write-Output "      -runtest [str] -    run verification named [str] and produce corresponding .VVP"
     Write-Output "      [Nothing]      -    builds all tests"
     

     exit
}

$old_dir = $PWD
$current_dir = $PSScriptRoot

Set-Location $current_dir

function Exit-Script {
     Set-Location $old_dir
     exit
}

if ($clear) {
     Remove-Item -Path "test/*" -Recurse

     mkdir test/vvp 2>$null

     Exit-Script
}

$files = Get-ChildItem -Recurse -Filter "rtl/*.sv" | % { $_.FullName }
$testbenches = Get-ChildItem -Path "verification/" -Recurse -Filter "*.sv" | % { $_.FullName }
$exclude = Get-ChildItem -Path "IP/" -Recurse -Filter "*.sv" | % { $_.FullName }
$topmodule = Get-ChildItem -Filter "topmodule.sv" | % { $_.FullName }

$files = $files | ? { $_ -notin $testbenches }
$files = $files | ? { $_ -ne $topmodule }
$files = $files | ? { $_ -notin $exclude }

mkdir test 2>$null
mkdir test/vvp 2>$null

foreach ($tb in $testbenches) {
     $name = (Get-Item $tb).BaseName
     if($need_runtest -and ($runtest -ne $name)) {
          continue
     }
     Write-Output "Processing: " + $name          

     $tbp = $name + ".vvp"

     iverilog -o test/vvp/$tbp -Icommon -g2012 $files $tb 

     if ($?) {
          if ($testall -or ($name -eq $runtest)) {
               Write-Output "Testing: " + $name
               Set-Location test
               vvp vvp/$tbp
          
               Set-Location ..
          }
     }
     else {
          Write-Error "Error in compiling, exiting..."
          Exit-Script
     }
     Write-Output "Done" "" ""
}

Exit-Script