$files = Get-ChildItem -Recurse -Filter "*.sv" | %{$_.FullName}

mkdir test

iverilog -o test/dsn -g2012 $files
cd test
vvp dsn
cd ..
gtkwave test/test.vcd 