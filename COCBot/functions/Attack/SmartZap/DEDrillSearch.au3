; #FUNCTION# ====================================================================================================================
; Name ..........: DEDrillSearch
; Description ...: Searches for the DE Drills in base, and returns; X&Y location, Bldg Level
; Syntax ........: DEDrillSearch([$bReTest = False])
; Parameters ....: $bReTest             - [optional] a boolean value. Default is False.
; Return values .: $aDrills Array with data on Dark Elixir Drills found in search
; Author ........: KnowJack (May 2015)
; Modified ......:
; Remarks .......: This file is part of ClashGameBot. Copyright 2015
;                  ClashGameBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================

Func DEDrillSearch($bReTest = False)
	;If $ichkDBLightSpell <> 1 Then Return False
	Local $aDrills[4][5] = [[-1, -1, -1, -1, 0], [-1, -1, -1, -1, 0], [-1, -1, -1, -1, 0], [-1, -1, -1, -1, 0]] ; [XCoord, YCoord, Level, AvailDE, #Zapped]
	Local $pixel[2], $result, $listPixelByLevel, $pixelWithLevel, $level, $pixelStr
	$numDEDrill = 0

	ZoomOut()
	; Checks the screen and stores the results as $result
	_WinAPI_DeleteObject($hBitmapFirst)
	$hBitmapFirst = _CaptureRegion2()
	$result = DllCall($LibDir & "\MBRfunctions.dll", "str", "getLocationDarkElixirExtractorWithLevel", "ptr", $hBitmapFirst)

	; Debugger
	;If $debugsetlog = 1 Then 
	;Setlog("Drill search $result[0] = " & $result[0], $COLOR_PURPLE) ;Debug

	$listPixelByLevel = StringSplit($result[0], "~") ; split each building into array
	
	If $result[0] = "" Then
		$numDEDrill = 0
		;SetLog("No Dark Elixir Drills found.", $COLOR_FUCHSIA)
	Else
		If UBound($listPixelByLevel) > 1 Then ; check for more than 1 bldg and proper split a part
			$numDEDrill = UBound($listPixelByLevel) - 1
			SetLog("Total No. of Dark Elixir Drills found = " & $numDEDrill, $COLOR_FUCHSIA)
			If $debugsetlog = 1 Then
				For $ii = 0 To $listPixelByLevel[0]
					Setlog("Drill search $listPixelByLevel[" & $ii & "] = " & $listPixelByLevel[$ii], $COLOR_PURPLE) ;Debug
				Next
			EndIf
		EndIf
	EndIf

	If $numDEDrill <> 0 Then		
		$iNbrOfDetectedDrillsForZap += $numDEDrill
		For $i = 0 To $numDEDrill
			If $numDEDrill > 1 Then
				$pixelWithLevel = StringSplit($listPixelByLevel[$i], "#")
				If @error Then ContinueLoop ; If the string delimiter is not found, then try next string.
			Else
				$pixelWithLevel = StringSplit($result[$i], "#")
			If @error Then ContinueLoop
			EndIf

			$level = $pixelWithLevel[1]
			$pixelStr = StringSplit($pixelWithLevel[2], "-")

			Local $pixel[2] = [$pixelStr[1], $pixelStr[2]]
			If isInsideDiamond($pixel)  Then
				$aDrills[$i][0] = Number($pixel[0])
				$aDrills[$i][1] = Number($pixel[1])
				$aDrills[$i][2] = Number($level)
				$aDrills[$i][3] = $DrillLevelHold[Number($level) - 1]
				;If $debugsetlog = 1 Then 
				SetLog("Dark Elixir Drill: [" & $aDrills[$i][0] & "," & $aDrills[$i][1] & "], Level: " & $aDrills[$i][2] & " " & $aDrills[$i][3], $COLOR_BLUE)
			Else
				;If $debugsetlog = 1 Then 
				SetLog("Dark Elixir Drill: [" & $pixel[0] & "," & $pixel[1] & "], Level: " & $level, $COLOR_PURPLE)
				;If $debugsetlog = 1 Then 
				SetLog("Found Drill Storage with Invalid Location?", $COLOR_RED)
			EndIf
		Next
	EndIf
	Return $aDrills
EndFunc   ;==>DEDrillSearch