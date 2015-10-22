@echo off
cls
if "%1"=="" goto makecd
goto copyloop

:copyloop
if "%1"=="" goto finish
if not exist %ramdrive%\FD11ISO\CONTENTS\%1\NUL MD %ramdrive%\FD11ISO\CONTENTS\%1
XCOPY /Q /Y /S %cddrive%\%1\*.* %ramdrive%\FD11ISO\CONTENTS\%1
ATTRIB -R -S -H /S %ramdrive%\FD11ISO\CONTENTS\%1\*.* > NUL
shift
goto copyloop

:finish
echo Done preparing files.
echo Please type CDR to complete the FreeDOS 1.1 remastering process.
echo This will add all files under %ramdrive%\FD11ISO to CD image file.
goto end

:makecd
xmssize -0 > nul
echo Currently there seems to be %errorlevel% MB of extended memory available.
DISKCOPY A: %ramdrive%\FD11ISO\CONTENTS\ISOLINUX\FDBOOT.IMG /o /x /d
mkisofs -q -boot-info-table -no-emul-boot -b isolinux/isolinux.bin -o %ramdrive%\FD11ISO\SHELL\ISOLINUX\FDBOOTCD.ISO %ramdrive%\FD11ISO\CONTENTS
if not "%errorlevel%"=="0" pause ERROR: MKISOFS generated return status code: %errorlevel%. Press a key to return
xcopy /Q /Y /S %ramdrive%\FD11ISO\CONTENTS\ISOLINUX\*.* %ramdrive%\FD11ISO\SHELL\ISOLINUX
ATTRIB -R -S -H /S %ramdrive%\FD11ISO\SHELL\ISOLINUX\*.* > NUL
mkisofs -boot-info-table -no-emul-boot -b isolinux/isolinux.bin -o %ramdrive%\FD11ISO\FDBOOTCD.ISO %ramdrive%\FD11ISO\SHELL
if not "%errorlevel%"=="0" pause ERROR: MKISOFS generated return status code: %errorlevel%. Press a key to return
CDD %ramdrive%\FD11ISO
echo.
echo Done creating/updating ISO9660 CD-image filesystem.
echo If you want to keep any changes, please copy final image files to a location
echo with permanent storage using the following command:
echo.
echo     COPY /Y %ramdrive%\FD11ISO\SHELL\ISOLINUX\FDBOOTCD.ISO %usbdrive%\ISO\FDBOOTCD.ISO
echo.
goto end

rem actions:
rem * Create directory structure
rem * Copy files (XCOPY /S)
rem * Remove write-only attribute (especially ramdisk image and isolinux.*)


:isoerror
echo Unable to create ISO9660 file out of ramdisk contents due to
echo one or more of the following reasons:
echo * not enough free disk space on ramdisk to store created ISO file
echo * not enough memory to succesfully run MKISOFS! At least 1MB XMS required
echo * no floppy image found on ramdisk
if not "%1"=="" goto finish
goto end

:end
