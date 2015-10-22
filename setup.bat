@echo off
rem ====== WHOAMI (detect shell, if not FreeCom, find & load it) ==========
if 01==0.1 goto 4dos
if not "%CD%"=="" goto cmd
rem 4DOS doesn't like below variable at all for some reason
if not "%ProgramFiles(x86)%"=="" goto cmd
if "%_CWD%"=="" goto other
set hello=
set /E hello=echo Hello World
if not "%hello%"=="Hello World" goto other
goto good

REM Above still goes wrong if this file is in path and simply gets called as SETUP.
REM MS COMMAND.COM will likely have same issue anyway.
REM use a FOR command to traverse through PATH? (1st hit should work, as PATH works same)
REM also could simply try 1st CD drive or all driveletters from D..Z

:cmd
echo Running CMD as command interpreter (ReactOS or Windows, 32bit/64bit)
echo Attempting to load 16bit FreeCOM 
if not "%ProgramFiles(x86)%"=="" goto winx64 
goto reload 

:4dos
rem might fail miserably under JPSOFT's Take Command..
VER /R
echo Currently running 4DOS as command interpreter, unsupported by this
echo batch script file. Loading FreeCOM instead
REM if not "%ProgramFiles(x86)%"=="" goto winx64 
set td=%@path[%_BATCHNAME%]
CDD %td%
set td=
goto reload

:other
rem See ftp://garbo.uwasa.fi/pc/link/tsbat.zip . Hope it doesn't call %0 again: infinite loop..
VER /R
echo Unrecognised command interpreter/shell running, loading FreeCOM instead
if not "%ProgramFiles(x86)%"=="" goto winx64 
echo Attempting to switch drive using undocumented DOS trick.
%0\
goto reload

:reload
echo Currently NOT running FreeCOM as shell, loading it
set hello=
rem Attempt to find FreeCOM, need CDD or CD /D
if not exist \freedos\setup\odin\command.com goto wrongfreecom
echo Reloading FreeCOM with parameters: %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
\FREEDOS\SETUP\ODIN\COMMAND.COM /K %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
echo A non-primary shell was closed or terminated by the EXIT command
echo Press Control-C to quit running this file or
pause
goto reload

:winx64
title FreeDOS 1.1 SETUP - installation aborted / not supported
rem cls 
echo FreeDOS 1.1 SETUP - installation aborted / not supported 
echo.
echo 64-bit Windows/ReactOS operating systems not supported due to
echo missing support for 16bit DOS/NTVDM subsystem, which is required for FreeCOM
echo.
echo Please burn ISO file as a CD on a recordable disc and start your system from it,
echo or use ISO file as virtual CD drive for your favourite emulation/virtualisation
echo product (QEMU, Bochs, VirtualBox, VirtualPC, VMware, Citrix/Xen, KVM etc).
echo.
if "%CD%"=="%userprofile%" goto end
if not "%_CWD%"=="" goto end
pause
goto end

:good
set hello=
VER /R
echo Running FreeCOM as current shell
if "%lang%"=="" set lang=EN
rem This works (SETUP) if started from correct directory/drive, or a drivename is in calling name (D:\SETUP or D:\SETUP.BAT),
rem yet fails miserably if not meeting those conditions (for example file is in PATH)
set /E thisfile=truename %0
if exist %thisfile%.bat set thisfile=%thisfile%.bat
if exist %thisfile% goto switchdir
for %%x in ( %path% ) do if exist %%x\%0 set /U thisfile=%%x\%0
for %%x in ( %path% ) do if exist %%x\%0.bat set /U thisfile=%%x\%0.bat
if exist %thisfile% goto switchdir
rem TRUENAME and MSCDEX (Win98 bootdisk) really don't like eachother, 
rem resulting in \\R.\A.\SETUP instead of R:\SETUP . The joy of "Installable Filesystem Drivers"..
if exist %0 goto switchdir
if exist %0.bat goto switchdir
echo Failed to find location of this file, which was invoked as %0.
echo Please switch to correct drive/directory and try again. Some debug info:
echo Current directory: %_CWD%
VER /R
SET
goto wrongdir

:switchdir
rem CDD works with files on latest FreeCOMs
if exist %0 CDD %0
if exist %0.bat CDD %0.bat
if exist %thisfile% CDD %thisfile%
set cddrv=%_CWD%
CD FREEDOS
set fdosroot=%_CWD%\Setup
set nlspath=%fdosroot%\nls
set path=%fdosroot%\ODIN;%fdosroot%\BATCH;%path%
if "%1"=="" goto begin
goto fd11

rem ============== FREEDOS 1.1 (%1 not empty) ============================

:fd11
for %%x in ( %1\PACKAGES\BASE\*.ZIP ) do if exist %%x goto custom
for %%x in ( %_CWD%\PACKAGES\BASE\*.ZIP ) do if exist %%x goto goodinst
echo SETUP could not find any packages to install, cancelling installation.
goto cleanup

:custom
CDD %1
goto goodinst

:goodinst
if exist %_CWD%\PACKAGES\BASE\SAMCFGX.ZIP set showpost=yes
set tz=UTC
rem TZ variable required external file (in path): UNZIP (Infozip 6.00)
if not exist c:\nul pause There's no drive C: present! Please reboot or press a key to continue
rem about 75MB required
INSTALL 
echo Package installation to harddisk completed.
rem Assuming INSTALL switched to target directory after finishing
rem Any errorlevels to consider for branching?
if exist POSTINST.BAT goto dopost
goto ramdir

:ramdir
if "%ramdrive%"=="" goto showpost
if not exist %ramdrive%\NUL goto showpost
if not "%ramdrive%"=="C:" goto showpost
SET /E /U fddir=DIR /S /B C:\POSTINST.BAT
if "%fddir%"=="" goto showpost
if not exist %fddir% goto showpost
CDD %fddir%
if exist POSTINST.BAT echo POSTINST.BAT found :)
if exist POSTINST.BAT set showpost=
if not exist POSTINST.BAT echo POSTINST.BAT *not* found :(
goto dopost

:showpost
if "%showpost%"=="" goto cleanup
set showpost=
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

:dopost
REM if "%2"=="" pause Press a key to finish installation by generating configuration files
call POSTINST.BAT
goto cleanup

:cleanup
set tz=
set thisfile=
goto end

rem ====================== FreeDOS 1.0 (LiveCD stuff???) ==============

:begin
shsurdrv /qq 100K,Z>NUL
if exist Z:\nul set TEMP=Z:\
REM cd\
REM if not exist FreeDOS\Setup\ODIN\*.* goto wrongdir
REM if !%lang%==! set lang=EN
REM set nlspath=%fdosroot%\nls
REM set cddrv=%_CWD%
REM set path=%cddrv%FreeDOS\Setup\ODIN;%path%
REM pushd
REM cd\
REM set fdosroot=%_CWD%FreeDOS\Setup
goto end
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
REM pause A choice ( %errorlevel% ) was made, processing now
goto skipkeyb

:skipkeyb
REM pause We've reached SKIPKEYB label
REM pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
call %fdosroot%\batch\getdrvs.bat %rd%\drvlist.txt %drives%
if not exist %rd%\drvlist.txt set destdrv=C:
if not exist %rd%\drvlist.txt goto skipselect
rem Check for only one available disk
getline %rd%\drvlist.txt 2>NUL
if not errorlevel 2 echo Drive C: is the only suitable partition, selecting...
if not errorlevel 2 set destdrv=C:
if not errorlevel 2 goto skipselect
if !%lang%==! set lang=en
set oldlang=%lang%
if not exist %fdosroot%\NLS\drvch.%lang% set lang=en
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
pbatch %fdosroot%\NLS\drvch.%lang% -fh1 -ft15 -x2 -y2
pbatch %rd%\drvlist.txt -fh1 -ft15 -m1 %usemse%
set lang=%oldlang%
cls
set /E destdrv=getline %rd%\drvlist.txt %errorlevel%
set finaldrv=
for %%x in ( %destdrv% ) do if not "%finaldrv%"=="" set finaldrv=%%x
set destdrv=%finaldrv%
set finaldrv=
goto skipselect

:skipselect
REM pause We've reached SKIPSELECT label
REM pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
if exist %rd%\drvlist.txt del %rd%\drvlist.txt
rem shsurdrv /qq /u>NUL
if !%destdrv%==! set destdrv=C:
rem Check if partition needs to be created
CDD %destdrv%\
if not !%_CWD%==!%destdrv%\ goto fdiskmenu
goto skipfdisk

:fdiskmenu
REM pause We've reached FDISKMENU label
cls
if !%lang%==! set lang=en
set oldlang=%lang%
if not exist fdskmen.%lang% set lang=en
REM pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
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
REM pause We've reached SKIPFDISK label
REM pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
cdd %destdrv%\
if not !%_CWD%==!%destdrv%\ goto format
ctty nul
mkdir test.tmp
if not exist test.tmp\nul goto format
if exist test.tmp\nul rmdir test.tmp
oscheck %destdrv% >NUL
ctty con
REM pause OSCHECK errorlevel: %errorlevel%
set os=%errorlevel%
if errorlevel 41 goto format
if !%os%==1 goto format
if !%os%==0 goto format
if !%os%==17 goto skipformat
for %%x in ( 39 38 36 35 34 ) do if "%os%"=="%%x" copy /b %fdosroot%\odin\meta-all.bin + %destdrv%\bootsect.bin + %fdosroot%\odin\metaboot.bot %destdrv%\metakern.sys >NUL
if exist bootsect.bin del bootsect.bin >NUL
goto skipformat

:format
ctty con
cls
REM pause We've reached FORMAT label
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
rem use "/Z:SERIOUSLY" as there's a GUI dialogue anyway?
rem How's the correct drive selected?
format %destdrv% /V:FREEDOS2012 /Q
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
rem On a blank disc FDISK doesn't write a bootsector, and MBR's message isn't
rem terribly helpful either. FORMAT doesn't write (nor preserve) a bootsector
rem either for a partition that's of PRIMARY type, FAT filesystem and happens
rem to be C:. Unlike MS FORMAT, it instead depends on SYS program
rem making errorlevel evaluation necessary if not wanting to write system files
rem Add Bootsector to freshly formatted drive without copying kernel/shell
SYS %destdrv% /bootonly
set locmsg=
set frmterr=
goto skipformat

:skipformat
ctty con
REM pause We've reached SKIPFORMAT label
pbatch %fdosroot%\NLS\backgrou.men -fh7 -ft7 -x1 -y1 -r0 -s0
if not exist %fdosroot%\batch\autorun.bat goto nocd
cdd %fdosroot%\batch
shsurdrv /u>NUL
autorun
goto end

:bootdisk
pause We've reached BOOTDISK label
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
goto unload

:wrongfreecom
echo.
echo "Why be difficult when, with a bit of effort, you could be impossible?"
echo.
echo Setup.bat requires FreeCOM 0.84pre2 or higher.  Please load this and
echo restart Setup.bat
goto unload

:unload
REM shsurdrv /qq /u>NUL
goto end

:end
