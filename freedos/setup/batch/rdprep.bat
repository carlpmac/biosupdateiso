@echo off
if "%cddrive%"=="" goto end
if "%usbdrive%"=="" goto end
rem Hopefully there's enough memory to cache the ISO file
%cddrive%\FREEDOS\SETUP\ODIN\XMSSIZE -0 > nul
if not errorlevel 20 goto end
echo Reading 16MB ISO file from USB 2.0 flash drive into system memory . . .
if exist %isofile% %cddrive%\FREEDOS\SETUP\ODIN\runtime %cddrive%\FREEDOS\SETUP\ODIN\SHSUCDRD /QQ /F:%isofile%
goto end
:end
set isofile=
