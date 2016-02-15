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
Local $vs2013 = RegRead($HKLM & "\SOFTWARE" & $Wow6432Node & "\Microsoft\DevDiv\vc\Servicing\12.0\RuntimeMinimum\", "Install")
If $vs2013 <> 1 Then
	RunWait(@ScriptDir & "\COCBot\Forecast\vcredist_x86.exe /install /quiet /norestart", "", @SW_HIDE)
EndIf
$tabForecast = GUICtrlCreateTabItem("Forecast")
	Local $x = 30, $y = 150
	$grpForecast = GUICtrlCreateGroup("Forecast", $x - 20, $y - 20, 450, 375)
	
	GUICtrlCreateObj($oIE, $x - 15, $y - 7, 444, 330)

	$y += 322
	$lblForecastSource = GUICtrlCreateLabel("Source: http://clashofclansforecaster.com", $x - 15, $y, 400, 20)
	$y += 16
	$lblForecastSource = GUICtrlCreateLabel("Utilizing: wkhtmltoimage - LGPLv3", $x - 15, $y, 400, 20)

	GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")
	
Func setForecast()
		_IENavigate($oIE, "about:blank")
		_IEBodyWriteHTML($oIE, "<div style='width:440px;height:250px;padding:0;overflow:hidden;position: absolute;top:50px;left:0px;z-index:0;'><center><img src='" & @ScriptDir & "\COCBot\Forecast\loading.gif'></center></div>")
		RunWait("..\COCBot\Forecast\wkhtmltoimage.exe http://clashofclansforecaster.com ..\COCBot\Forecast\forecast.jpg", "", @SW_HIDE)
		_IEBodyWriteHTML($oIE, "<div style='width:526px;height:330px;padding:0;overflow:scroll;position: absolute;top:-3px;left:-86px;z-index:0;'><img src='" & @ScriptDir & "\COCBot\Forecast\forecast.jpg' width='820'></div>")
EndFunc

Func redrawForecast()
	If GUICtrlRead($tabMain, 1) = $tabForecast Then
		_IENavigate($oIE, "about:blank")
		_IEBodyWriteHTML($oIE, "<div style='width:526px;height:330px;padding:0;overflow:scroll;position: absolute;top:-3px;left:-86px;z-index:0;'><img src='" & @ScriptDir & "\COCBot\Forecast\forecast.jpg' width='820'></div>")
	EndIf
EndFunc
