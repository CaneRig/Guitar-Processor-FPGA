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
     Write-Output "      -runtest [str] -    run verification named [str] and produce corresponding .VVP"
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
function HLine {
     Write-Output ("-" * $Host.UI.RawUI.WindowSize.Width)
}

if ($clear) {
     Remove-Item -Path "test/*" -Recurse

     mkdir test/vvp 2>$null

     Exit-Script
}

$files = Get-ChildItem -Path "rtl" -Recurse -Filter "*.sv" | % { $_.FullName }
$testbenches = Get-ChildItem -Path "verification" -Recurse -Filter "*.sv" | % { $_.FullName }
$exclude = Get-ChildItem -Path "rtl/IP" -Recurse -Filter "*.sv" | % { $_.FullName }
$exclude += Get-ChildItem -Path "rtl/io" -Recurse -Filter "*.sv" | % { $_.FullName }
$topmodule = Get-ChildItem -Path "rtl" -Filter "topmodule.sv" | % { $_.FullName }
$thrdparties = Get-ChildItem -Path "thrd-patry" -Recurse -Directory | Where-Object { $_.Name -eq "rtl" } | ForEach-Object { Get-ChildItem -Path $_.FullName -Recurse -File | Where-Object { $_.Extension -eq ".sv" } } | Select-Object -ExpandProperty FullName

HLine
Write-Output "Source files: " $files
HLine
Write-Output "Thrd-party files: " $thrdparties
HLine
Write-Output "Testbenches files: " $testbenches
HLine
Write-Output "Excluded files: " $exclude
HLine
Write-Output "Topmodule file: " $topmodule
HLine
HLine
HLine

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

     HLine
     Write-Output "Processing: " + $name          

     $tbp = $name + ".vvp"

     iverilog -o test/vvp/$tbp -Icommon -g2012 $files $thrdparties $tb 

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