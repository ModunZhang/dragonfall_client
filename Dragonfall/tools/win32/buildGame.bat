:: This scripts only for windows phone on Win32
:: dannyhe
@echo off
:begin
echo -------------------------------------------
echo * Build Game Tools Windows Phone Only v0.1
echo 1. build Lua
echo 2. build Resources
echo 3. clean 
echo 4. clean,build Lua,build Resources
echo 5. close
echo ------------------------------------------
set/p option="input option:":
if "%option%"=="1" goto lua
if "%option%"=="2" goto res 
if "%option%"=="3" goto clean 
if "%option%"=="4" goto all 
if "%option%"=="5" goto close 
goto begin
:clean
echo ------------------------------------------
echo * Clean Game Data
echo ------------------------------------------
python cleanGame.py
echo ------------------------------------------
echo * Finish Build.
pause
goto begin
:lua
echo ------------------------------------------
echo * Build Lua
echo ------------------------------------------
python buildScripts.py
echo ------------------------------------------
echo * Finish Build.
pause
goto begin
:res 
echo ------------------------------------------
echo * Build Resources
echo ------------------------------------------
python buildRes.py
echo ------------------------------------------
echo * Finish Build.
pause
goto begin
:all
echo ------------------------------------------
echo * Clean Game Data
echo ------------------------------------------
python cleanGame.py
echo ------------------------------------------
echo * Build Lua
echo ------------------------------------------
python buildScripts.py
echo ------------------------------------------
echo * Build Resources
echo ------------------------------------------
python buildRes.py
echo ------------------------------------------
echo * Finish Build.
pause
goto begin
:close
echo ------------------------------------------
echo * Close Game Tools
echo ------------------------------------------
pause
exit