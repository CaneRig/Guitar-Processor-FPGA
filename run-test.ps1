$files = Get-ChildItem -Recurse -Filter "*.sv" | %{$_.FullName}
$testbenches = Get-ChildItem -Path "./verification/" -Recurse -Filter "*.sv" | %{$_.FullName}

$files = $files | ? {$_ -notin $testbenches}

mkdir test 2>$null
mkdir test/vvp 2>$null

foreach ($tb in $testbenches){
     $tbp = (Get-Item $tb).BaseName + ".vvp"

     iverilog -o test/vvp/$tbp -g2012 $files $tb 

     if($?)
     {
          cd test
          vvp vvp/$tbp
          
          cd ..
     }else{
          Write-Error "Error in compiling, exiting..."
          exit
     }
     Write-Output "Done\n\n"
}

exit
if($?)
{
     cd test
     vvp dsn.vvp
     
     cd ..
}

Convert-Path