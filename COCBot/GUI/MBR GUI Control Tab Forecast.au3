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
Local $vs2013 = RegRead($HKLM & "\SOFTWARE" & $Wow6432Node & "\Microsoft\DevDiv\vc\Servicing\12.0\RuntimeMinimum\", "Install")
If $vs2013 <> 1 Then
	RunWait(@ScriptDir & "\COCBot\Forecast\vcredist_x86.exe /install /quiet /norestart", "", @SW_HIDE)
EndIf

Func chkForecastPause()
	If GUICtrlRead($chkForecastPause) = $GUI_CHECKED Then
		_GUICtrlEdit_SetReadOnly($txtForecastPause, False)
		GUICtrlSetState($txtForecastPause, $GUI_ENABLE)
	Else
		_GUICtrlEdit_SetReadOnly($txtForecastPause, True)
		GUICtrlSetState($txtForecastPause, $GUI_DISABLE)
	EndIf
EndFunc

Func chkForecastBoost()
	If GUICtrlRead($chkForecastBoost) = $GUI_CHECKED Then
		_GUICtrlEdit_SetReadOnly($txtForecastBoost, False)
		GUICtrlSetState($txtForecastBoost, $GUI_ENABLE)
	Else
		_GUICtrlEdit_SetReadOnly($txtForecastBoost, True)
		GUICtrlSetState($txtForecastBoost, $GUI_DISABLE)
	EndIf
EndFunc

Func setForecast()
	_IENavigate($oIE, "about:blank")
	_IEBodyWriteHTML($oIE, "<div style='width:440px;height:250px;padding:0;overflow:hidden;position: absolute;top:50px;left:0px;z-index:0;'><center><img src='" & @ScriptDir & "\COCBot\Forecast\loading.gif'></center></div>")

	RunWait("..\COCBot\Forecast\wkhtmltoimage.exe --width 3100 http://clashofclansforecaster.com ..\COCBot\Forecast\forecast.jpg", "", @SW_HIDE)

	;Local $iPID = Run("..\COCBot\Forecast\wkhtmltoimage.exe --width 3100 http://clashofclansforecaster.com ..\COCBot\Forecast\forecast.jpg", "", @SW_HIDE)
	;While ProcessWaitClose($iPID, 1) <> 1 And @error = 0
	;	Sleep(1000)
	;Wend
	;ReDim $dtStamps[0]
	;ReDim $lootMinutes[0]
	;Local $forecast = readCurrentForecast()
	;SetLog("Current Forecast: " & StringFormat("%.1f", $forecast))
	_IEBodyWriteHTML($oIE, "<img style='margin: -10px 0px -10px -100px;' src='" & @ScriptDir & "\COCBot\Forecast\forecast.jpg' width='1700'>")

EndFunc

Func _RoundDown($nVar, $iCount)
    Return Round((Int($nVar * (10 ^ $iCount))) / (10 ^ $iCount), $iCount)
EndFunc

Func redrawForecast()
	;Return
	If GUICtrlRead($tabMain, 1) = $tabForecast Then
		_IENavigate($oIE, "about:blank")
		_IEBodyWriteHTML($oIE, "<img style='margin: -10px 0px -10px -100px;' src='" & @ScriptDir & "\COCBot\Forecast\forecast.jpg' width='1700'>")
	EndIf
EndFunc

Func readCurrentForecast()
	Local $return = getCurrentForecast()
	If $return > 0 Then Return $return

	Local $line = ""
	Local $filename = @ScriptDir & "\COCBot\Forecast\forecast.mht"

	SetLog("Reading Forecast", $COLOR_BLUE)

	_INetGetMHT( "http://clashofclansforecaster.com", $filename)

	Local $file = FileOpen($filename, 0)
	If $file = -1 Then
		SetLog("     Error reading forecast!", $COLOR_RED)
		Return False
	EndIf

	ReDim $dtStamps[0]
	ReDim $lootMinutes[0]
	While 1
		$line = FileReadLine($file)
		If @error <> 0 Then ExitLoop
		;SetLog($line)
		if StringCompare(StringLeft($line, StringLen("<script language=""javascript"">var militaryTime")), "<script language=""javascript"">var militaryTime") = 0 Then
			;\"minuteNow\":1455599460,

			; \"dtStamps\":[1455584400,1455584460],\"totals\":{\"lootMinutes\":[28185749,1676883,1676783]},
			Local $pos1
			Local $pos2

			$pos1 = StringInStr($line, "minuteNow")
			If $pos1 > 0 Then
				$pos1 = StringInStr($line, ":", 0, 1, $pos1 + 1)
				If $pos1 > 0 Then
					$pos2 = StringInStr($line, ",", 9, 1, $pos1 + 1)
					Local $minuteNowString = StringMid($line, $pos1 + 1, $pos2 - $pos1 - 1)
					$timeOffset = Int($minuteNowString) - nowTicksUTC()
					;SetLog("now UTC        : " & nowTicksUTC())
					;SetLog("minuteNowString: " & $minuteNowString)
					SetLog("     timeOffset: " & $timeOffset, $COLOR_BLUE)
				EndIf
			EndIf

			$pos1 = StringInStr($line, "dtStamps")
			If $pos1 > 0 Then
				$pos1 = StringInStr($line, "[", 0, 1, $pos1 + 1)
				If $pos1 > 0 Then
					$pos2 = StringInStr($line, "]", 9, 1, $pos1 + 1)
					Local $dtStampsString = StringMid($line, $pos1 + 1, $pos2 - $pos1 - 1)
					$dtStamps = StringSplit($dtStampsString, ",", 2)
				EndIf
			EndIf

			$pos1 = StringInStr($line, "lootMinutes", 0, 1, $pos1 + 1)
			If $pos1 > 0 Then
				$pos1 = StringInStr($line, "[", 0, 1, $pos1 + 1)
				If $pos1 > 0 Then
					$pos2 = StringInStr($line, "]", 9, 1, $pos1 + 1)
					Local $minuteString = StringMid($line, $pos1 + 1, $pos2 - $pos1 - 1)
					$lootMinutes = StringSplit($minuteString, ",", 2)
				EndIf
			EndIf

			;\"maxLootMinute\":\"38118568\",\"maxPlayersOnline\":\"266630\",\"lootIndexScaleMarkers\":[6648957,10838957,15028957,19218957,23408957,27598957,31787957,35977957,40167957,44357957]}');getStatsResponse('{\"currentLoot\":{\"totalPlayers\":48516592,\"trend\":1,
			;\"lootMinutes\":364398175,\"lootMinuteChange\":3127850,\"playersOnline\":5607450,\"playersOnlineChange\":-23550,\"shieldedPlayers\":40226650,\"shieldedPlayersChange\":-12525,\"attackablePlayers\":6750500,\"attackablePlayersChange\":13125},\"mainColorShadeNow\":\"F79269\",
			;\"lootIndexString\":\"2.8\",\"bgColor\":\"FDC68A\",\"fgColor\":\"7D4900\",\"forecastWordNow\":\"TERRIBLE\",
			;\"forecastMessages\":{\"english\":\"Loot available is TERRIBLE right now.  This will continue for the next 6 hours 43 minutes when it will improve to be OKAY.  Loot will continue improving to be DECENT in about 7 hours 39 minutes from now.\",

			$pos1 = StringInStr($line, "lootIndexScaleMarkers", 0, 1, $pos1 + 1)
			If $pos1 > 0 Then
				$pos1 = StringInStr($line, "[", 0, 1, $pos1 + 1)
				If $pos1 > 0 Then
					$pos2 = StringInStr($line, "]", 9, 1, $pos1 + 1)
					Local $lootIndexScaleMarkersString = StringMid($line, $pos1 + 1, $pos2 - $pos1 - 1)
					$lootIndexScaleMarkers = StringSplit($lootIndexScaleMarkersString, ",", 2)
				EndIf
			EndIf

			;$pos1 = StringInStr($line, "maxLootMinute", 0, 1, $pos1 + 1)
			;If $pos1 > 0 Then
			;	$pos1 = StringInStr($line, ":", 0, 1, $pos1 + 1)
			;	If $pos1 > 0 Then
			;		$pos1 += 2
			;		$pos2 = StringInStr($line, "\", 9, 1, $pos1 + 1)
			;		$maxLootMinute = StringMid($line, $pos1 + 1, $pos2 - $pos1 - 1)
			;		SetLog("maxLootMinute: " & $maxLootMinute)
			;	EndIf
			;EndIf

			;$pos1 = StringInStr($line, "lootMinutes", 0, 1, $pos1 + 1)
			;If $pos1 > 0 Then
			;	$pos1 = StringInStr($line, ":", 0, 1, $pos1 + 1)
			;	If $pos1 > 0 Then
			;		$pos2 = StringInStr($line, ",", 9, 1, $pos1 + 1)
			;		$curLootMinutes = StringMid($line, $pos1 + 1, $pos2 - $pos1 - 1)
			;		SetLog("curLootMinutes: " & $curLootMinutes)
			;	EndIf
			;EndIf

			;$pos1 = StringInStr($line, "lootIndexString", 0, 1, $pos1 + 1)
			;If $pos1 > 0 Then
			;	$pos1 = StringInStr($line, ":", 0, 1, $pos1 + 1)
			;	If $pos1 > 0 Then
			;		$pos1 += 2
			;		$pos2 = StringInStr($line, "\", 9, 1, $pos1 + 1)
			;		$lootIndex = Number(StringMid($line, $pos1 + 1, $pos2 - $pos1 - 1), 3)
			;		SetLog("lootIndex: " & $lootIndex)
			;	EndIf
			;EndIf

			ExitLoop
		EndIf
	WEnd
	FileClose($file)

	SetLog("     Processed " & UBound($lootMinutes) & " loot minutes.", $COLOR_BLUE)

	$return = getCurrentForecast()
	If $return = 0 Then
		SetLog("Error parsing forecast.")
	EndIf
	Return $return
EndFunc

Func _INetGetMHT( $url, $file )
	Local $msg = ObjCreate("CDO.Message")
	If @error Then Return False
	Local $ado = ObjCreate("ADODB.Stream")
	If @error Then Return False
	Local $conf = ObjCreate("CDO.Configuration")
	If @error Then Return False

	With $ado
		.Type = 2
		.Charset = "US-ASCII"
		.Open
	EndWith

	Local $flds = $conf.Fields
	$flds.Item("http://schemas.microsoft.com/cdo/configuration/urlgetlatestversion") = True
	$flds.Update()
	$msg.Configuration = $conf
	$msg.CreateMHTMLBody($url, 31)
	$msg.DataSource.SaveToObject($ado, "_Stream")
	FileDelete($file)
	$ado.SaveToFile($file, 1)
	$msg = ""
	$ado = ""
	Return True
EndFunc

Func getCurrentForecast()
	Local $return = 0
	Local $nowTicks = nowTicksUTC() + $timeOffset ; + 240
	;SetLog($nowUTC)
	;SetLog("nowTicks=" & $nowTicks)
	If UBound($dtStamps) > 0 And UBound($lootMinutes) > 0 And UBound($dtStamps) = UBound($lootMinutes) Then
		;SetLog("minTicks=" & Int($dtStamps[0]))
		;SetLog("maxTicks=" & Int($dtStamps[UBound($dtStamps) - 1]))

		If $nowTicks >= Int($dtStamps[0]) And $nowTicks <= Int($dtStamps[UBound($dtStamps) - 1]) Then
			Local $i
			For $i = 0 To UBound($dtStamps) - 1
				If $nowTicks >= Int($dtStamps[$i]) Then
					$return = Int($lootMinutes[$i])
				Else
					ExitLoop
				EndIf
			Next
		Else
			Return 0
		EndIf
	Else
		Return 0
	EndIf

	Return CalculateIndex($return)
	;SetLog("parsedMinutes: " & $return)
	;SetLog("actualIndex: " & $lootIndex)
	;SetLog("calculatedIndex: " & (($return - 6648957) / 4190000) + 1)


	;SetLog("calculated max: " & $return / $lootIndex)
	;6648957,10838957,15028957,19218957,23408957,27598957,31787957,35977957,40167957,44357957
	;loot index = ((minutes-lvl1) / 4190000) + 1
	;Return (($return - 6648957) / 4190000) + 1 ;pulled from http://clashofclansforecaster.com/main.js - maxTotalLootMinuteBalance = 44739594
EndFunc

Func CalculateIndex($minutes)
	;lootIndexScaleMarkers\":[6648957,10838957,15028957,19218957,23408957,27598957,31787957,35977957,40167957,44357957]
	;pulled from http://clashofclansforecaster.com/main.js - maxTotalLootMinuteBalance = 44739594
	Local $index = 0
	If $minutes < $lootIndexScaleMarkers[0] Then
		$index = $minutes / $lootIndexScaleMarkers[0]
	ElseIf $minutes < $lootIndexScaleMarkers[1] Then
		$index = (($minutes - $lootIndexScaleMarkers[0]) / ($lootIndexScaleMarkers[1] - $lootIndexScaleMarkers[0])) + 1
	ElseIf $minutes < $lootIndexScaleMarkers[2] Then
		$index = (($minutes - $lootIndexScaleMarkers[1]) / ($lootIndexScaleMarkers[2] - $lootIndexScaleMarkers[1])) + 2
	ElseIf $minutes < $lootIndexScaleMarkers[3] Then
		$index = (($minutes - $lootIndexScaleMarkers[2]) / ($lootIndexScaleMarkers[3] - $lootIndexScaleMarkers[2])) + 3
	ElseIf $minutes < $lootIndexScaleMarkers[4] Then
		$index = (($minutes - $lootIndexScaleMarkers[3]) / ($lootIndexScaleMarkers[4] - $lootIndexScaleMarkers[3])) + 4
	ElseIf $minutes < $lootIndexScaleMarkers[5] Then
		$index = (($minutes - $lootIndexScaleMarkers[4]) / ($lootIndexScaleMarkers[5] - $lootIndexScaleMarkers[4])) + 5
	ElseIf $minutes < $lootIndexScaleMarkers[6] Then
		$index = (($minutes - $lootIndexScaleMarkers[5]) / ($lootIndexScaleMarkers[6] - $lootIndexScaleMarkers[5])) + 6
	ElseIf $minutes < $lootIndexScaleMarkers[7] Then
		$index = (($minutes - $lootIndexScaleMarkers[6]) / ($lootIndexScaleMarkers[7] - $lootIndexScaleMarkers[6])) + 7
	ElseIf $minutes < $lootIndexScaleMarkers[8] Then
		$index = (($minutes - $lootIndexScaleMarkers[7]) / ($lootIndexScaleMarkers[8] - $lootIndexScaleMarkers[7])) + 8
	ElseIf $minutes < $lootIndexScaleMarkers[9] Then
		$index = (($minutes - $lootIndexScaleMarkers[8]) / ($lootIndexScaleMarkers[9] - $lootIndexScaleMarkers[8])) + 9
	Else
		$index = (($minutes - $lootIndexScaleMarkers[9]) / (44739594 - $lootIndexScaleMarkers[9])) + 10
	EndIf

	SetLog("Calculated Index: " & $index, $COLOR_BLUE)
	Return _RoundDown($index, 1)
EndFunc


Func nowTicksUTC()
	Local $now = _Date_Time_GetSystemTime()
	Local $nowUTC = _Date_Time_SystemTimeToDateTimeStr($now)

	; convert 02/16/2016 07:02:06 to 2016/02/16 07:02:06
	;         12345678901
	$nowUTC = StringMid($nowUTC, 7, 4) & "/" & StringMid($nowUTC, 1, 2) & "/" & StringMid($nowUTC, 4, 2) & StringMid($nowUTC, 11)
	Return _DateDiff('s', "1970/01/01 00:00:00", $nowUTC)

EndFunc

Func checkForecastBoost($forecast, $troopName)
	Local $return = False
	If $iChkForecastBoost = 1 Then
		If $currentForecast >= Number($iTxtForecastBoost, 3) Then
			SetLog("Boosting " & $troopName & ": forecast:" & StringFormat("%.1f", $forecast) & " >= setting:" & $iTxtForecastBoost, $COLOR_BLUE)
			$return = True
		Else
			SetLog("Not Boosting " & $troopName & ": forecast:" & StringFormat("%.1f", $forecast) & " < setting:" & $iTxtForecastBoost, $COLOR_RED)
		EndIf
	EndIf
	Return $return
EndFunc

Func checkForecastPause($forecast)
	Local $return = False
	If $iChkForecastPause = 1 Then
		If $currentForecast <= Number($iTxtForecastPause, 3) Then
			SetLog("Halting attacks: forecast:" & StringFormat("%.1f", $forecast) & " <= setting:" & $iTxtForecastPause, $COLOR_RED)
			$return = True
		Else
			SetLog("Not Halting attacks: forecast:" & StringFormat("%.1f", $forecast) & " > setting:" & $iTxtForecastPause, $COLOR_BLUE)
		EndIf
	EndIf
	Return $return
EndFunc