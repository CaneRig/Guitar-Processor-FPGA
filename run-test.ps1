$files = Get-ChildItem -Recurse -Filter "*.sv" | %{$_.FullName}


iverilog -o dsn -g2012 $files
vvp dsn
gtkwave 