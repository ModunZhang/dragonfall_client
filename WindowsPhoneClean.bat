@echo off
title Windows Phone 8.1 Clean
echo ---------------------------------------------------------
echo Visual Studio的清理后Windows Phone 8.1打包仍失败的情况下
echo 关闭Visual Studio后执行该脚本后再执行打包。
echo ---------------------------------------------------------
pause
echo ---------------------------------------------------------
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\2d\libcocos2d_8_1\libcocos2d_8_1\libcocos2d_8_1.Windows\Debug"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\2d\libcocos2d_8_1\libcocos2d_8_1\libcocos2d_8_1.WindowsPhone\Debug"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\editor-support\spine\proj.win8.1-universal\libSpine.Windows\Debug"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\editor-support\spine\proj.win8.1-universal\libSpine.WindowsPhone\Debug"
rd /s /q "Dragonfall\frameworks\cocos2d-x\external\Box2D\proj.win8.1-universal\libbox2d.Windows\Debug"
rd /s /q "Dragonfall\frameworks\cocos2d-x\external\Box2D\proj.win8.1-universal\libbox2d.WindowsPhone\Debug"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\App.Windows\Debug"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\App.WindowsPhone\Debug"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\Debug"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\ipch"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\scripting\lua-bindings\proj.wp8.1\LibLua\Debug"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\quick_libs\proj.wp8.1\quick_libs\Debug"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\App.Windows\Generated Files"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\App.WindowsPhone\Generated Files"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\2d\libcocos2d_8_1\libcocos2d_8_1\libcocos2d_8_1.WindowsPhone\ARM"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\2d\libcocos2d_8_1\libcocos2d_8_1\libcocos2d_8_1.WindowsPhone\Release"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\editor-support\spine\proj.win8.1-universal\libSpine.WindowsPhone\ARM"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\editor-support\spine\proj.win8.1-universal\libSpine.WindowsPhone\Release"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\quick_libs\proj.wp8.1\quick_libs\ARM\Debug"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\quick_libs\proj.wp8.1\quick_libs\ARM\Release"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\quick_libs\proj.wp8.1\quick_libs\Release"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\scripting\lua-bindings\proj.wp8.1\LibLua\ARM"
rd /s /q "Dragonfall\frameworks\cocos2d-x\cocos\scripting\lua-bindings\proj.wp8.1\LibLua\Release"
rd /s /q "Dragonfall\frameworks\cocos2d-x\external\Box2D\proj.win8.1-universal\libbox2d.WindowsPhone\ARM"
rd /s /q "Dragonfall\frameworks\cocos2d-x\external\Box2D\proj.win8.1-universal\libbox2d.WindowsPhone\Release"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\ARM\Debug"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\ARM\Release"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\App.WindowsPhone\ARM"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\App.WindowsPhone\Release"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\Release"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\App.Windows\Release"
rd /s /q "Dragonfall\frameworks\runtime-src\proj.win8.1-universal\App.Windows\ARM"
rd /s /q "external\WindowsPhone\FBWinSDK\FBWinSDK\FBWinSDK.Windows\ARM"
rd /s /q "external\WindowsPhone\FBWinSDK\FBWinSDK\FBWinSDK.Windows\Generated Files"
rd /s /q "external\WindowsPhone\FBWinSDK\FBWinSDK\FBWinSDK.WindowsPhone\ARM"
rd /s /q "external\WindowsPhone\FBWinSDK\FBWinSDK\FBWinSDK.WindowsPhone\Generated Files"
rd /s /q "external\WindowsPhone\FBWinSDK\FBWinSDK\FBWinSDK.Windows\Debug"
rd /s /q "external\WindowsPhone\FBWinSDK\FBWinSDK\FBWinSDK.WindowsPhone\Debug"
rd /s /q "external\WindowsPhone\FBWinSDK\FBWinSDK\FBWinSDK.WindowsPhone\Release"
rd /s /q "external\WindowsPhone\FBWinSDK\FBWinSDK\FBWinSDK.Windows\Release"
echo ---------------------------------------------------------
echo 脚本执行完成
echo ---------------------------------------------------------
pause
exit