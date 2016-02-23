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
Global $tabForecast
Global $grpForecast
Global $ieForecast

$tabForecast = GUICtrlCreateTabItem("Forecast")
	Local $x = 30, $y = 150
	$grpForecast = GUICtrlCreateGroup("Forecast", $x - 20, $y - 20, 450, 375)
	
	$ieForecast = GUICtrlCreateObj($oIE, $x - 15, $y - 7, 440, 315)

	$y += 310
	$lblForecastSource = GUICtrlCreateLabel("Source: http://clashofclansforecaster.com", $x + 220, $y + 4, 400, 20)
	$lblForecastSource = GUICtrlCreateLabel("Uses: wkhtmltoimage", $x + 220, $y + 23, 400, 20)

	$chkForecastBoost = GUICtrlCreateCheckbox("Boost when above", $x, $y, -1, -1)
		$txtTip = "Boost Barracks, Spells, and/or Heroes (Specified on the Troops tab) when the loot index is above the specified value."
		GUICtrlSetTip(-1, $txtTip)
		GUICtrlSetOnEvent(-1, "chkForecastBoost")
	$txtForecastBoost = GUICtrlCreateInput("6.0", $x + 110, $y + 2, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
		$txtTip = "Minimum loot index for boosting."
		GUICtrlSetLimit(-1, 3)
		GUICtrlSetTip(-1, $txtTip)
		_GUICtrlEdit_SetReadOnly(-1, True)
		GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 20
	$chkForecastPause = GUICtrlCreateCheckbox("Halt when below", $x, $y, -1, -1)
		$txtTip = "Halt attacks when the loot index is below the specified value."
		GUICtrlSetTip(-1, $txtTip)
		GUICtrlSetOnEvent(-1, "chkForecastPause")
	$txtForecastPause = GUICtrlCreateInput("2.0", $x + 110, $y + 2, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
		$txtTip = "Minimum loot index for halting attacks."
		GUICtrlSetLimit(-1, 3)
		GUICtrlSetTip(-1, $txtTip)
		_GUICtrlEdit_SetReadOnly(-1, True)
		GUICtrlSetState(-1, $GUI_DISABLE)
		
	GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")

