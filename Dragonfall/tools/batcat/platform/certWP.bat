::---------------------------------------------------
:: Using the Windows App Certification Kit to test package
:: useage: certWP.bat filePath
:: Date: 2016/05/16
:: by dannyhe
::---------------------------------------------------
@echo off

set CERTCMDTOOL="C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe"
set OUTFILE=%~p1report.xml

echo./*
echo. * Validate the app package for Windows Phone 8.1
echo. */
echo.
%CERTCMDTOOL% reset
%CERTCMDTOOL% test -appxpackagepath %~f1 -reportoutputpath %OUTFILE%