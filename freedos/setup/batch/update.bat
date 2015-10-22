@echo off
goto init

:filecopy
shift
rem don't copy if already exist at target destination
if exist %2\%3 goto end
rem don't copy if source don't exist.
if not exist %1\%3 goto end
copy /y %1\%3 %2\%3
goto end

:init
if "%1"=="" goto error
for %%x in ( %1 %1\CONTENTS %1\SHELL %1\CONTENTS\ISOLINUX %1\SHELL\ISOLINUX ) do if not exist %%x\NUL MD %%x
echo * Directory structure present
CDD %1
if "%2"=="done" goto done
goto initcdex

:initcdex
rem If installed, clears all drives, if not installed yet, installs.
SHSUCDX /D9 /QQ
rem Clears all drives, easier than complete uninstall and reinstall
SHSUCDX /D9 /QQ
if exist SHSU-CDR goto addcdex
if exist FDCD0000 goto addcdex
goto skipcd

:addcdex
if exist SHSU-CDR call cdrom SHSU-CDR
if exist SHSU-CDR goto copyCD
rem only mount Eltorito drive if no ramdrive yet
if exist FDCD0000 call cdrom FDCD0000
if "%cdrom%"=="" goto skipCD
if exist %cdrom%\setup.bat goto copyCD
echo El-Torito driver loaded for physical CD instead of Memdisk-ISO
echo Skipping CD copying (until disk mounting implemented)
goto skipcd

:copyCD
set path=%bootdrv%;%bootdrv%\;%bootdrv%\DRIVER;%bootdrv%\FREEDOS;R:;R:\;%cdrom%;%cdrom%\;%cdrom%\FREEDOS\SETUP\ODIN
echo * Path adjusted, time to copy stuff from CD
if exist %cdrom%\autorun.inf copy /y %cdrom%\autorun.inf %1\shell\autorun.inf > NUL
if exist %cdrom%\isolinux\memdisk copy /y %cdrom%\isolinux\memdisk %1\shell\isolinux > NUL
if exist %cdrom%\isolinux\isolinux.bin copy /y %cdrom%\isolinux\isolinux.bin %1\shell\isolinux > NUL
if exist %cdrom%\isolinux\isolinux.cfg copy /y %cdrom%\isolinux\isolinux.cfg %1\shell\isolinux > NUL
if exist %cdrom%\isolinux\menu.c32 copy /y %cdrom%\isolinux\menu.c32 %1\shell\isolinux > NUL
if exist %cdrom%\isolinux\chain.c32 copy /y %cdrom%\isolinux\chain.c32 %1\shell\isolinux > NUL
echo * Taking shortcut by copying CD instead of contents (XCOPY/ATTRIB)
if exist %1\shell\isolinux\fdbootcd.iso del %1\shell\isolinux\fdbootcd.iso
XCOPY /S %cdrom%\*.* %1\contents
ATTRIB -R -S -H %1\*.* /S
if exist %1\contents\isolinux\fdboot.img DEL %1\contents\isolinux\fdboot.img
if exist %1\contents\boot.cat del %1\contents\boot.cat
echo * Done copying files from CD
if "%2"=="done" goto done
echo * Please finalise by typing the following command:
echo    %0 %1 done
goto end

:skipcd
echo * Skipping CD copy, let's see how far we get :)
goto end

:error
echo.
echo Welcome to the FreeDOS 1.1 update script
echo.
echo To eliminate the possibility of file corruption we've set up
echo a number of requirements which needs to be met.
echo.
echo You've failed to match one or more of the following requirements:
echo * bootdrive has to be A: (Memdisk)
echo * contents of FreeDOS ISO image file has to be in RAM
echo * no disk-backed images present
echo * no physical CD driver loaded.
echo * Ramdisk R: has to exist, be writable with free space
goto end

:done
if not exist %1\shell\isolinux\isolinux.bin goto initcdex
echo Creating updated bootdisk image
if not exist %1\shell\isolinux\fdboot.img diskcopy A: %1\shell\isolinux\fdboot.img /o /x /d
if exist %1\contents\isolinux\isolinux.bin copy /y %1\shell\isolinux\fdboot.img %1\contents\isolinux\fdboot.img
echo Checking directory structure for valid boot image files:
if not exist %1\shell\isolinux\fdbootcd.iso echo Creating inner ISO file
if not exist %1\shell\isolinux\fdbootcd.iso mkisofs -boot-info-table -no-emul-boot -b isolinux/isolinux.bin -o %1\SHELL\ISOLINUX\FDBOOTCD.ISO %1\CONTENTS
echo Creating image file
mkisofs -boot-info-table -no-emul-boot -b isolinux/isolinux.bin -o %1\FDBOOTCD.ISO %1\SHELL
goto succes

:succes
echo Done creating/updating ISO9660 CD-image filesystem
echo.
if exist %1\shell\isolinux\fdbootcd.iso echo Simple image found at %1\shell\isolinux\fdbootcd.iso
if exist %1\fdbootcd.iso echo Shell image found at %1\fdbootcd.iso
if exist SHSU-CDR goto end
if exist FDCD0000 goto end
echo (Images were created without CD content!)
goto end
:end
