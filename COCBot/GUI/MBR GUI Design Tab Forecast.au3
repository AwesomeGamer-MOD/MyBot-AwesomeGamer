; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file Includes GUI Design
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: AwesomeGamer (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

;~ -------------------------------------------------------------
; Forecast Tab
;~ -------------------------------------------------------------
#include <IE.au3>
Local $oIE = ObjCreate("Shell.Explorer.2")

RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", "MyBot.run.exe", "REG_DWORD", "11000")
RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", "AutoIt3.exe", "REG_DWORD", "11000")
0
$tabForecast = GUICtrlCreateTabItem("Forecast")
	Local $x = 30, $y = 150
	$grpForecast = GUICtrlCreateGroup("Forecast", $x - 20, $y - 20, 450, 375)
	
	GUICtrlCreateObj($oIE, $x - 15, $y, 444, 335)
;GUISetState()

	_IENavigate($oIE, "about:blank")
	_IEBodyWriteHTML($oIE, "<div style='width:6px;height:226px;position:absolute;top:105px;left:161px;background-color: #000000;z-index:1;'></div><div style='width:521px;height:335px;padding:0;overflow:hidden;position: absolute;top:-4px;left:-81px;z-index:0;'><iframe style='zoom:48%;margin:0;width:1200px;height:740px' src='http://clashofclansforecaster.com/' frameBorder='0'></div>")

	$y += 335
	$lblForecastSource = GUICtrlCreateLabel("Source: http://clashofclansforecaster.com", $x + 223, $y, 400, 20)
	;GUICtrlSetFont(-1, 8.5, $FW_BOLD)
	
	
	GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")
