:: This scripts only for windows phone on Win32
:: dannyhe
@echo off
::
set current=%~dp0
set tp_dir=%current%\..\..\PackImages\TexturePackerProj\wp
set tp_out_dir=%current%\..\..\dev\res\images\_Compressed_wp
set export_tools=%current%\..\scripts\plist_texture_data_to_lua.py
set lua_export=%current%\..\..\dev\scripts\app\texture_data_wp.lua
if not exist %tp_out_dir%\*.png (
	echo export tps files
	for %%i in (%tp_dir%\*.tps) do TexturePacker "%%i"
)

if not exist %lua_export% (
	echo export lua file
	python %export_tools% -p %tp_out_dir% -o %lua_export%
)