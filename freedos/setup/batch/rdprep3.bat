@echo off
if "%cddrive%"=="" goto error
rem Determine amount of memory for RAMDISK, XMS manager limited to 4095MB
%cddrive%\FREEDOS\SETUP\ODIN\XMSSIZE 1 > nul
if errorlevel 26 set size=%errorlevel%00
if errorlevel 40 set size=4000
if not "%size%"=="" goto load
%cddrive%\FREEDOS\SETUP\ODIN\xmssize 10 > nul
if errorlevel 26 set size=%errorlevel%0
if not "%size%"=="" goto load
%cddrive%\FREEDOS\SETUP\ODIN\xmssize -0 > nul
set size=%errorlevel%
if errorlevel 63 goto load
DEVLOAD /DC TDSK.EXE
for %%x in ( %drives% ) do if errorlevel H%%x set /U ramdrive=%%x:
if not "%size%"=="0" TDSK.EXE %SIZE%
if "%size%"=="0" TDSK.EXE 100K
goto common
:load
if "%size%"=="" %cddrive%\FREEDOS\SETUP\ODIN\SHSURDRV /QQ /D:2000M
if not "%size%"=="" %cddrive%\FREEDOS\SETUP\ODIN\SHSURDRV /QQ /D:%size%M
if errorlevel 27 goto end
for %%x in ( %drives% ) do if errorlevel H%%x set /U ramdrive=%%x:
if not exist %ramdrive%\NUL goto error
:common
echo Following drives are present now:
if not "%RAMDRIVE%"=="" echo %RAMDRIVE% (writeable %size%MB ramdisk, acts as storage disk till reboot)
if not "%USBDRIVE%"=="" echo %USBDRIVE% (writeable USB Flash Drive, for persistent storage of files)
if not "%CDDRIVE%"=="" echo %CDDRIVE% (read-only ramdisk, virtual CD-ROM for FreeDOS 1.1 installation)
for %%x in ( FD11ISO FD11ISO\CONTENTS FD11ISO\SHELL FD11ISO\SHELL\ISOLINUX ) do if not exist %RAMDRIVE%\%%x\NUL MD %RAMDRIVE%\%%x
for %%x in ( FD11ISO\CONTENTS\FREEDOS FD11ISO\CONTENTS\ISOLINUX TEMP ) do if not exist %RAMDRIVE%\%%x\NUL MD %RAMDRIVE%\%%x
COPY A:\COMMAND.COM %RAMDRIVE%\TEMP\COMMAND.COM > NUL
REM if not "%size%"=="0" COPY %CDDRIVE%\ISOLINUX\*.* %RAMDRIVE%\FD11ISO\SHELL\ISOLINUX\*.* > NUL
if not "%size%"=="0" COPY %CDDRIVE%\ISOLINUX\*.* %RAMDRIVE%\FD11ISO\CONTENTS\ISOLINUX\*.* > NUL
if not "%size%"=="0" COPY %CDDRIVE%\AUTORUN.INF  %RAMDRIVE%\FD11ISO\CONTENTS\AUTORUN.INF > NUL
if not "%size%"=="0" COPY %CDDRIVE%\SETUP.BAT  %RAMDRIVE%\FD11ISO\CONTENTS\SETUP.BAT > NUL
%CDDRIVE%\FREEDOS\SETUP\ODIN\attrib /s -r -s -h %RAMDRIVE%\*.* > NUL
SET TEMP=%RAMDRIVE%\TEMP
SET TMP=%TEMP%
SET COMSPEC=%TEMP%\COMMAND.COM
SET PATH=%PATH%;%CDDRIVE%\FREEDOS\SETUP\ODIN;%CDDRIVE%\FREEDOS\SETUP\BATCH
echo.
echo Type %cddrive%\SETUP to start installation of FreeDOS 1.1
goto end

:error
echo An error occurred, no specific details, sorry.
goto end
:help
echo Help not implemented right now, sorry
goto end
:end