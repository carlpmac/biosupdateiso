@echo off
if 01==0.1 goto 4dos
if not "%CD%"=="" goto cmd
rem 4DOS doesn't like below variable at all for some reason
if not "%ProgramFiles(x86)%"=="" goto cmd
if "%_CWD%"=="" goto other
set hello=
set /E hello=echo Hello World
if not "%hello%"=="Hello World" goto other
goto good

:cmd
echo Running CMD as command interpreter (ReactOS or Windows, 32bit/64bit)
echo Attempting to load 16bit FreeCOM 
if not "%ProgramFiles(x86)%"=="" goto winx64 
goto reload 

:4dos
rem might fail miserably under JPSOFT's Take Command..
echo Currently running 4DOS as command interpreter, unsupported by this
echo batch script file. Loading FreeCOM instead
REM if not "%ProgramFiles(x86)%"=="" goto winx64 
goto reload

:other
echo Unrecognised command interpreter/shell running, loading FreeCOM instead
if not "%ProgramFiles(x86)%"=="" goto winx64 
goto reload

:reload
echo Currently NOT running FreeCOM as shell, loading it
set hello=
if not exist c:\fdos\bin\command.com goto abort
echo Reloading FreeCOM with parameters: %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
C:\FDOS\BIN\COMMAND.COM /K %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
echo A non-primary shell was closed or terminated by the EXIT command
goto end

:abort
echo Failed to load FreeCOM as new shell, aborting
if not "%ProgramFiles(x86)%"=="" goto winx64 
goto end

:winx64
title FreeDOS 1.1 SETUP - installation aborted / not supported
rem cls 
echo FreeDOS 1.1 SETUP - installation aborted / not supported 
echo.
echo 64-bit Windows/ReactOS operating systems not supported due to
echo missing support for 16bit DOS/NTVDM subsystem, which is required for FreeCOM
echo.
echo Please burn ISO file as a CD and start your system from it.
if "%CD%"=="%userprofile%" goto end
if not "%_CWD%"=="" goto end
pause
goto end

:good
set hello=
echo Running FreeCOM as current shell
if not "%1"=="" goto setupnow
goto begin

:setupnow
if "%lang%"=="" set lang=EN
set /E thisfile=truename %0
if exist %thisfile%.bat set thisfile=%thisfile%.bat
rem CDD works with files on latest FreeCOMs
CDD %thisfile%
set cddrv=%_CWD%
CD FREEDOS
for %%x in ( %1\PACKAGES\BASE\*.ZIP ) do if exist %%x goto custom
for %%x in ( %_CWD%\PACKAGES\BASE\*.ZIP ) do if exist %%x goto goodinst
echo SETUP could not find any packages to install, cancelling installation.
goto cleanup

:custom
CDD %1
goto goodinst

:goodinst
set fdosroot=%_CWD%\Setup
set nlspath=%fdosroot%\nls
set path=%fdosroot%\ODIN;%path%
set tz=UTC
rem TZ variable required external file (in path): UNZIP (Infozip 6.00)
INSTALL 
echo Package installation to harddisk completed.
if not exist POSTINST.BAT goto dirmsg
pause Press a key to finish installation by generating configuration files
call POSTINST.BAT
goto cleanup

:dirmsg
echo Please switch to wherever you installed FreeDOS,
echo and type POSTINST to generate configuration files
echo (config.sys / autoexec.bat)
echo.
echo Diagnostic info:
echo SETUP called as: %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
echo SETUP file is: %thisfile% 
rem echo SETUP started checking for packages at %cddrv%\PACKAGES\BASE\
if not exist C:\NUL echo No drive C: found, run Fdisk?
goto cleanup

:cleanup
set cddrv=
set fdosroot=
set nlspath=
set path=
set tz=
set thisfile=
goto end

:begin
shsurdrv /qq 100K,Z>NUL
set TEMP=Z:\
cd\
if not exist FreeDOS\Setup\ODIN\*.* goto wrongdir
set /E hello=echo hello world
if !%hello%==! goto wrongfreecom
set hello=
if !%lang%==! set lang=EN
set nlspath=%fdosroot%\nls
set cddrv=%_CWD%
set path=%cddrv%FreeDOS\Setup\ODIN;%path%
pushd
cd\
set fdosroot=%_CWD%FreeDOS\Setup

rem Time to select the language
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
pbatch %fdosroot%\NLS\lang.txt -fh1 -ft15 -x2 -y2
pbatch %fdosroot%\NLS\langsel.txt -fh1 -ft15 -m1 %usemse%
cls
set choice=%errorlevel%
rem English here should not load Display or Keyb unnecessarily
if !%choice%==!1 goto skipkeyb
if !%choice%==!2 call %fdosroot%\batch\regional.bat 10
if !%choice%==!3 call %fdosroot%\batch\regional.bat 8
if !%choice%==!4 call %fdosroot%\batch\regional.bat 56
if !%choice%==!5 call %fdosroot%\batch\regional.bat 34
if !%choice%==!6 call %fdosroot%\batch\regional.bat 12
if !%choice%==!7 call %fdosroot%\batch\regional.bat 18
if !%choice%==!8 call %fdosroot%\batch\regional.bat 36
if !%choice%==!9 call %fdosroot%\batch\regional.bat 17
if !%choice%==!10 call %fdosroot%\batch\regional.bat 37
if not !%choice%==!11 goto skipkeyb
type %fdosroot%\language\regional.txt
echo.
echo.
echo Please enter the number corresponding to the name which best describes
set /P choice=your current location (confirm input by pressing ENTER):
if not "%choice%"=="" call %fdosroot%\batch\regional.bat %choice%

:skipkeyb
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
call %fdosroot%\batch\getdrvs.bat Z:\drvlist.txt
if not exist z:\drvlist.txt set destdrv=C:
if not exist z:\drvlist.txt goto skipselect
rem Check for only one available disk
getline z:\drvlist.txt 2>NUL
if not errorlevel 2 echo Drive C: is the only suitable partition, selecting...
if not errorlevel 2 set destdrv=C:
if not errorlevel 2 goto skipselect
if !%lang%==! set lang=en
set oldlang=%lang%
if not exist %fdosroot%\NLS\drvch.%lang% set lang=en
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
pbatch %fdosroot%\NLS\drvch.%lang% -fh1 -ft15 -x2 -y2
pbatch z:\drvlist.txt -fh1 -ft15 -m1 %usemse%
set lang=%oldlang%
cls
set choice=%errorlevel%
set /E destdrv=getline z:\drvlist.txt %choice%

:skipselect
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
del z:\drvlist.txt
rem shsurdrv /qq /u>NUL
if !%destdrv%==! set destdrv=C:

rem Check if partition needs to be created
CDD %destdrv%\
if not !%_CWD%==!%destdrv%\ goto fdiskmenu
goto skipfdisk

:fdiskmenu
cls
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
if !%lang%==! set lang=en
set oldlang=%lang%
if not exist fdskmen.%lang% set lang=en
pbatch %fdosroot%\nls\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
pbatch %fdosroot%\nls\title.%lang% -fh1 -ft15 -x2 -y2
pbatch %fdosroot%\nls\fdskmen.%lang% -fh1 -ft15 -m1 %usemse%
set lang=%oldlang%
cls
set choice=%errorlevel%
if errorlevel 5 goto fdiskmenu
if errorlevel 4 Fdapm WARMBOOT
if "%choice%"=="2" goto end
if "%choice%"=="3" goto bootdisk
if "%choice%"=="1" XFdisk
set choice=
goto fdiskmenu

:skipfdisk
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
cdd %destdrv%\
if not !%_CWD%==!%destdrv%\ goto format
mkdir test.tmp
if not exist test.tmp\nul goto format
rmdir test.tmp
oscheck %destdrv% >NUL
set os=%errorlevel%
if errorlevel 41 goto format
if !%os%==1 goto format
if !%os%==0 goto format
if !%os%==17 goto skipformat
for %%x in ( 39 38 36 35 34 ) do if "%os%"=="%%x" copy /b %fdosroot%\odin\meta-all.bin + %destdrv%\bootsect.bin + %fdosroot%\odin\metaboot.bot %destdrv%\metakern.sys >NUL
if exist bootsect.bin del bootsect.bin >NUL
goto skipformat

:format
cls
set frmterr=
if !%lang%==! set lang=en
set oldlang=%lang%
if not exist frmt.%lang% set lang=en
pbatch %fdosroot%\nls\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
pbatch %fdosroot%\nls\frmt.%lang% -fh1 -ft15 -x2 -y2
pbatch %fdosroot%\nls\yesno.%lang% -fh1 -ft15 -m1
set lang=%oldlang%
cls
if errorlevel 3 goto format
if errorlevel 2 goto end
format %destdrv% /V:FREEDOS2011 /Q
echo FORMAT status: %errorlevel%
set frmterr=%errorlevel%
set /e locmsg=localize /f bdisk 0.3 @@@ Could not format your hard disk
if not !%frmterr%==!0 pause %locmsg%
if not !%frmterr%==!0 goto format
echo >%destdrv%\test.tmp
if not exist %destdrv%\test.tmp pause %locmsg%
if not exist %destdrv%\test.tmp goto format
del %destdrv%\test.tmp
pushd
cdd %fdosroot%\odin
rem SYS %destdrv% %destdrv%>NUL
popd
set locmsg=
set frmterr=

:skipformat
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
if not exist %fdosroot%\batch\autorun.bat goto nocd
cdd %fdosroot%\batch
shsurdrv /u>NUL
autorun
goto end

:bootdisk
localize /f bdisk 0.4 @@@ This creates a FreeDOS boot disk on your first floppy drive
localize /f bdisk 0.5 @@@ Please insert a formatted floppy disk into that drive
pause
if not !%initrd%==! set destdsk=b:
if !%initrd%==! set destdsk=a:
%cddrv%FreeDOS\3rdParty\extract %cddrv%ISOLinux\Data\FDBoot.img -x x:%destdsk%\
sys %destdsk% /BOOTONLY
set destdsk=
pause
goto fdiskmenu

:wrongdir
echo Setup.bat started from the wrong directory.  It should be started from
echo the directory where it resides.
shsurdrv /qq /u>NUL
goto end

:wrongfreecom
echo Setup.bat requires FreeCOM 0.84pre2 or higher.  Please load this and
echo restart Setup.bat
shsurdrv /qq /u>NUL
goto end

:end
