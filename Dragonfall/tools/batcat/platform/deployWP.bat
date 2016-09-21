::---------------------------------------------------
:: Deploy the Windows Phone app to device
:: Useage: deployWP.bat filePath
:: Date: 2016/05/16
:: by dannyhe
::---------------------------------------------------

@echo off
set CMDTOOL="C:\Program Files (x86)\Microsoft SDKs\Windows Phone\v8.1\Tools\AppDeploy\AppDeployCmd.exe"
set PRODUCT_ID=aa155f39-6b85-4c52-a388-4eacd55bbcb5
if not exist %~f1 (
	echo file is not exist: %~f1
	goto ERROR
)

::echo./*
::echo. * Uninstall Dragonfall windows phone project from device...
::echo. */
::echo.

::%CMDTOOL% /uninstall %PRODUCT_ID% /targetdevice:de

echo./*
echo. * Install Dragonfall windows phone project to device...
echo. */
echo.

%CMDTOOL% /install %~f1 /targetdevice:de

goto EOF

:ERROR
pause
exit

:EOF
echo finish!
pause