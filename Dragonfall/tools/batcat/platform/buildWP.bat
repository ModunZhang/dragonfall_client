:: build the Windows Phone Project for visual studio 2013
:: by dannyhe
:: useage: buildWP.bat [OutDir]
@echo off
echo./*
echo. * Check VC++ environment...
echo. */
echo.

set FOUND_VC=0
set FOUND_OUTDIR=0

if not "%~1"=="" set FOUND_OUTDIR=1

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
echo. * Building Dragonfall Windows Phone Project...
echo. */
echo.
call %VSVARS%
if %FOUND_VC%==1 (
	if %FOUND_OUTDIR%==0 (
		msbuild  ..\..\..\frameworks\runtime-src\proj.win8.1-universal\App.WindowsPhone\Dragonfall.WindowsPhone.vcxproj /p:Configuration="Release"  /p:Platform="ARM" /t:Clean;Rebuild
	) else (
		msbuild  ..\..\..\frameworks\runtime-src\proj.win8.1-universal\App.WindowsPhone\Dragonfall.WindowsPhone.vcxproj /p:Configuration="Release"  /p:Platform="ARM" /t:Clean;Rebuild /p:OutDir=%~f1
	)
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