@echo off
echo ---------------------------------
echo * Build Game ? Windows Phone Only
echo ---------------------------------
pause
echo ---------------------------------
echo * Clean Game Data
echo ---------------------------------
python cleanGame.py
echo ---------------------------------
echo * Build Lua
echo ---------------------------------
python buildScripts.py
echo ---------------------------------
echo * Build Resources
echo ---------------------------------
python buildRes.py
echo ---------------------------------
echo * Finish Build.
pause
exit

::choice /c 12 /m 请输入你的选择：
::if errorlevel 2 echo 你输入了2
::if errorlevel 1 echo 你输入了1
::pause