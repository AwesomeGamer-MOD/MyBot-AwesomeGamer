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
Global $oIE = ObjCreate("Shell.Explorer.2")
RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", "IECapt.exe", "REG_DWORD", "11000")
	
$tabForecast = GUICtrlCreateTabItem("Forecast")
	Local $x = 30, $y = 150
	$grpForecast = GUICtrlCreateGroup("Forecast", $x - 20, $y - 20, 450, 375)
	
	GUICtrlCreateObj($oIE, $x - 15, $y, 444, 335)

	$y += 335
	$lblForecastSource = GUICtrlCreateLabel("Source: http://clashofclansforecaster.com", $x + 223, $y, 400, 20)

	GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")
	
Func setForecast()
		_IENavigate($oIE, "about:blank")
		_IEBodyWriteHTML($oIE, "<div style='width:440px;height:250px;padding:0;overflow:hidden;position: absolute;top:50px;left:0px;z-index:0;'><center><img src='" & @ScriptDir & "\COCBot\Forecast\loading.gif'></center></div>")
		RunWait("..\COCBot\Forecast\IECapt.exe --url=http://clashofclansforecaster.com/ --out=..\COCBot\Forecast\forecast.jpg --max-wait=3000 --silent", "", @SW_HIDE)
		_IEBodyWriteHTML($oIE, "<div style='width:521px;height:335px;padding:0;overflow:scroll;position: absolute;top:-3px;left:-83px;z-index:0;'><img src='" & @ScriptDir & "\COCBot\Forecast\forecast.jpg' width='820'></div>")
EndFunc

Func redrawForecast()
	If GUICtrlRead($tabMain, 1) = $tabForecast Then
		_IENavigate($oIE, "about:blank")
		_IEBodyWriteHTML($oIE, "<div style='width:521px;height:335px;padding:0;overflow:scroll;position: absolute;top:-3px;left:-83px;z-index:0;'><img src='" & @ScriptDir & "\COCBot\Forecast\forecast.jpg' width='820'></div>")
	EndIf
EndFunc
