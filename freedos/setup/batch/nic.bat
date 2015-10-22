@echo off
if "%1"=="" goto help
BERNDPCI %1%2
if "%errorlevel%"=="0" goto foundnic
if "%errorlevel%"=="255" goto error
if "%3"=="" goto foundnic
for %%x in ( %3 %3.com %3.exe) do if exist %%x goto loadpkt
goto foundnic

:foundnic
if "%errorlevel%"=="1" echo Found 1 network interface card with PCI vendor ID %1 and PCI device ID %2 (%1:%2)
if not "%errorlevel%"=="1" echo Found %errorlevel% network interface cards with PCI vendor ID %1 and PCI device ID %2 (%1:%2)
goto end

:loadpkt
if "%errorlevel%"=="1" echo Loading packet driver %3 for network interface card with PCI vendor ID %1 and PCI device ID %1
if errorlevel 2 echo Loading packet driver %3 for %errorlevel% network interface cards with PCI vendor ID %1 and PCI device ID %1
if "%4"=="" set pktcmd=%3 0x60
if not "%4"=="" set pktcmd=%3 %4 %5 %6 %7 %8 %9
if not "%pktcmd%"=="" LH %PKTCMD%
goto end

:error
echo This computer does not seem to contain a "Peripheral Component Interconnect"
echo bus (also known under the names of PCI, PCI-X, PCIe and PCI-Express). Unable 
echo to auto-detect network cards, if any are present.
goto end

:help
goto end

:end