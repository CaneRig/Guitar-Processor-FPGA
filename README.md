# Guitar-Processor-FPGA
An implementation of guitar processor on MAX10 FPGA Board 
## Testing
You can run verification via powershell script:
```ps1
> .\run-test.ps1 
```

Options:
- -help - outputs commands
- -clear - removes "test/" folder and exits
- -notest - compile without running verification 

## Features
- [ ] gain
- [x] overdrive
- [ ] applying other combo amp's IR
- [ ] reverb
- [ ] echo