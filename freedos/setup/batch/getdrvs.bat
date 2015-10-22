@echo off
rem if it is a non-CD-ROM hard drive, drive:\nul will exist.  Do not check
rem for floppy drives at this point (would installing to a floppy even work??)
if not "%2"=="" goto newstyle
:oldstyle
for %%x in ( C D E F G H I J K L M N O P Q R S T U V W Y ) do if exist %%x:\NUL echo %%x: [nnn MB available space]>>%1
goto end

:newstyle
if "%rd%"=="" goto oldstyle
if not exist %rd%\nul goto oldstyle
if exist %rd%\drvlist.txt del %rd%\drvlist.txt
if exist C:\NUL goto loop
echo C: [Unable to determine amount of free space]>%rd%\drvlist.txt
goto end

:loop
if "%1"=="" goto end
if not exist %1:\NUL goto next
if "%1:"=="%RD%" goto next
if "%1:"=="%ramdisk%" goto next
freetest %1: 5 > nul
if not errorlevel 1 goto next
if not errorlevel 10  echo %1: [  %errorlevel%MB available space]>>%rd%\drvlist.txt
if not errorlevel 100 echo %1: [ %errorlevel%MB available space]>>%rd%\drvlist.txt
if errorlevel 100     echo %1: [%errorlevel%MB available space]>>%rd%\drvlist.txt
goto next

:next
shift
goto loop

:end
