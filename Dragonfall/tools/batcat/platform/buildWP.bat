@echo off
echo./*
echo. * Check VC++ environment...
echo. */
echo.

set FOUND_VC=0

if defined VS120COMNTOOLS (
    set VSTOOLS="%VS120COMNTOOLS%"
    set VC_VER=120
    set FOUND_VC=1
) 

set VSTOOLS=%VSTOOLS:"=%
set "VSTOOLS=%VSTOOLS:\=/%"
set VSVARS="%VSTOOLS%vsvars32.bat"
if not defined VSVARS (
    echo Can't find VC2013 installed!
    goto ERROR
)
echo./*
echo. * Building Dragonfall Windows Phone Project ...
echo. */
echo.
call %VSVARS%
if %FOUND_VC%==1 (
msbuild  ..\..\..\frameworks\runtime-src\proj.win8.1-universal\App.WindowsPhone\Dragonfall.WindowsPhone.vcxproj /p:Configuration="Release"  /p:Platform="ARM" /t:Clean;Rebuild
) else (
    echo Script error.
    goto ERROR
)
goto EOF
:ERROR
pause
:EOF
echo finish!
pause