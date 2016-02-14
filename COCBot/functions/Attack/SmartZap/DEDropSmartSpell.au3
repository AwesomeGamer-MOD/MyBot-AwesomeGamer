; #FUNCTION# ====================================================================================================================
; Name ..........: DEDropSmartSpell, checkDE
; Description ...: DEDropSmartSpell - Grabs DE drill info. Selects Lightning spell and drops the spell at a
; 				   point, depending on criteria
; Syntax ........: DEDropSmartSpell(), checkDE()
; Parameters ....:
; Return values .: DEDropSmartSpell - None; checkDE - False or value if found
; Author ........: drei3000 (July 2015)
; Modified ......:
; Remarks .......:This file is part of ClashGameBot. Copyright 2015
;                  ClashGameBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================

Func DEDropSmartSpell()
	Local Const $strikeOffsets = [1, 3]
	Local $searchDark, $aDarkDrills, $DEDrillChanged = False, $oldDark = 0, $Spell, $strikeGain = 0, $smartZapGain = 0, $expectedDE = 0

	; Check if target is DE zap match
	;If Not($zapBaseMatch) Then Return False
	
	SetLog("Checking DE drills to Zap", $COLOR_BLUE)
	
	; Get Dark Elixir value, if no DE value exists, exit.
	$searchDark = checkDE()
	If $searchDark = False Then
		SetLog("Could not determine the target's Dark Elixir value", $COLOR_RED)
		Return False
	EndIf
	
	; Get Drill locations and info
	$aDarkDrills = DEDrillSearch()
	If $numDEDrill > 0 Then
		$DEperDrill = (Number($searchDark) / $numDEDrill)
		If $debugsetlog = 1 Then SetLog("DE/drill: " & $DEperDrill, $COLOR_PURPLE)
		If $DEperDrill < Number($itxtDBLightMinDark) Then
			SetLog("DE drills contain less than " & $itxtDBLightMinDark & " DE/drill, not worth zapping", $COLOR_RED)
			Return False
		EndIf
	Else
		SetLog("No DE drills were found for zapping", $COLOR_RED)
		Return False
	EndIf
	$iZapVillageFound += 1

	; Select Lightning Spell and update number of spells left
	For $i = 0 To UBound($atkTroops) - 1
		If $atkTroops[$i][0] = $eLSpell Then
			$Spell = $i
			$CurLightningSpell = $atkTroops[$i][1]
			SelectDropTroop($Spell)
		EndIf
	Next
	$maxElixirSpellNbr = $CurLightningSpell
	;If $debugsetlog = 1 Then 
	;SetLog("Max number of spell is: " & $maxElixirSpellNbr, $COLOR_PURPLE)
	;If $debugsetlog = 1 Then 
	SetLog("Number of Lightning Spells: " & $CurLightningSpell, $COLOR_PURPLE)
	If $CurLightningSpell = 0 Then Return False

	; Offset the zap criteria for th8 and lower
	Local $drillLvlOffset = 0
	If $iTownHallLevel = 8 Then
		$drillLvlOffset = 1
	ElseIf $iTownHallLevel < 8 Then
		$drillLvlOffset = 2
	EndIf
	;If $debugsetlog = 1 Then 
	;SetLog("Drill Level Offset is: " & $drillLvlOffset, $COLOR_PURPLE)

	; Sort by remaining DE
	_ArraySort($aDarkDrills, 1, 0, 0, 3)
	;If $debugsetlog = 1 Then 
	;SetLog("Levels of drills: " & $aDarkDrills[0][3] & " " & $aDarkDrills[1][3] & " " & $aDarkDrills[2][3] & " " & $aDarkDrills[3][3], $COLOR_PURPLE)

	While $CurLightningSpell > 0 And $aDarkDrills[0][3] <> -1 And $maxElixirSpellNbr <> 0
		If $DEDrillChanged Then ; if a DE drill has been removed, check remaining DE/drill number
			If $numDEDrill > 0 Then
				$DEperDrill = (Number($searchDark) / $numDEDrill)
				If $debugsetlog = 1 Then SetLog("DE/drill: " & $DEperDrill, $COLOR_PURPLE)
				If $DEperDrill < Number($itxtDBLightMinDark) Then
					SetLog("DE drills contain less than " & $itxtDBLightMinDark & " DE/drill, not worth zapping", $COLOR_RED)
					Return False
				EndIf
				$DEDrillChanged = False ; reset flag after check
			Else
				SetLog("No DE drills worth zapping left", $COLOR_RED)
				ExitLoop
			EndIf
		EndIf
		
		; If you have most of your spells, drop lightning on level 3+ de drill
		If $CurLightningSpell/$maxElixirSpellNbr >= 0.7 And $aDarkDrills[0][2] >= (3 - $drillLvlOffset) Then
			;If $debugsetlog = 1 Then 
			;SetLog("First condition: Attack level 3+ drill if you have most of spells.", $COLOR_PURPLE)
			SetLog("Zapping DE Drill.", $COLOR_PURPLE)
			
			Click($aDarkDrills[0][0] + $strikeOffsets[0], $aDarkDrills[0][1] + $strikeOffsets[1], 1)
			$CurLightningSpell -= 1
			$iLightSpellUsed += 1
			$aDarkDrills[0][4] += 1
			If _Sleep(3500) Then Return True
		; else if you have half of your spells, drop lightning on level 4+ de drill
		ElseIf $CurLightningSpell/$maxElixirSpellNbr >= 0.4 And $CurLightningSpell/$maxElixirSpellNbr <= 0.7 And $aDarkDrills[0][2] >= (4 - $drillLvlOffset) Then
			;If $debugsetlog = 1 Then 
			;SetLog("Second condition: Attack level 4+ drills if you have half of spells", $COLOR_PURPLE)
			SetLog("Zapping DE Drill.", $COLOR_PURPLE)
			Click($aDarkDrills[0][0] + $strikeOffsets[0], $aDarkDrills[0][1] + $strikeOffsets[1], 1)
			$CurLightningSpell -= 1
			$iLightSpellUsed += 1
			$aDarkDrills[0][4] += 1
			If _Sleep(3500) Then Return True
		; else if the collector is level 5+ and collector is more than 30% full
		ElseIf $aDarkDrills[0][2] >= (5 - $drillLvlOffset) And ($aDarkDrills[0][3]/$DrillLevelHold[$aDarkDrills[0][2] - 1]) > 0.3 Then
			;If $debugsetlog = 1 Then 
			;SetLog("Third condition: Attack level 5+ drills if it's more than 30% full", $COLOR_PURPLE)
			SetLog("Zapping DE Drill.", $COLOR_PURPLE)
			Click($aDarkDrills[0][0] + $strikeOffsets[0], $aDarkDrills[0][1] + $strikeOffsets[1], 1)
			$CurLightningSpell -= 1
			$iLightSpellUsed += 1
			$aDarkDrills[0][4] += 1
			If _Sleep(3500) Then Return True
		Else
			;If $debugsetlog = 1 Then 
			SetLog("No suitable drills. Removing current drill from list.", $COLOR_PURPLE)
			For $i = 0 To 3
				$aDarkDrills[0][$i] = -1
			Next
			$numDEDrill -= 1
			$DEDrillChanged = True
		EndIf

		$oldDark = $searchDark
		$searchDark = checkDE()
		If $searchDark = False Then ExitLoop ; In case proper color isn't detected for the DE

		$strikeGain = $oldDark - $searchDark
		$iDEFromZap += $strikeGain
		If $aDarkDrills[0][2] <> -1 Then
			$expectedDE = ($DrillLevelSteal[($aDarkDrills[0][2] - 1)] * 0.75)
		Else
			$expectedDE = -1
		EndIf

		; If change in DE is less than expected, remove the Drill from list. else, subtract change from assumed total
		If $strikeGain < $expectedDE And $expectedDE <> -1 Then
			For $i = 0 To 3
				$aDarkDrills[0][$i] = -1
			Next
			$numDEDrill -= 1
			$DEDrillChanged = True
			;If $debugsetlog = 1 Then 
			SetLog("Gained: " & $strikeGain & " Expected: " & $expectedDE, $COLOR_PURPLE)
		Else
			$aDarkDrills[0][3] -= $strikeGain
			;If $debugsetlog = 1 Then 
			SetLog("Gained: " & $strikeGain & ". Adjusting amount left in this drill.", $COLOR_PURPLE)
		EndIf
		
		; remove drills that has already been zapped twice
		If $aDarkDrills[0][4] > 1 Then
			;If $debugsetlog = 1 Then 
			SetLog("DE drill (" & $aDarkDrills[0][0] & ", " & $aDarkDrills[0][0] &") has been zapped twice, removing it from targets.", $COLOR_PURPLE)
			For $i = 0 To 3
				$aDarkDrills[0][$i] = -1
			Next
			$numDEDrill -= 1
			$DEDrillChanged = True
		EndIf

		If $strikeGain > 0 Then
			$smartZapGain += $strikeGain
			SetLog("DE from zap: " & $strikeGain & " Total DE from smartZap: " & $smartZapGain, $COLOR_FUCHSIA)
		EndIf

		; Sort array by the assumed capacity available, and if all drills removed from array, then exit while loop
		_ArraySort($aDarkDrills, 1, 0, 0, 3)
		;If $debugsetlog = 1 Then 
		SetLog("DE Left in Collectors: " & $aDarkDrills[0][3] & " " & $aDarkDrills[1][3] & " " & $aDarkDrills[2][3] & " " & $aDarkDrills[3][3], $COLOR_PURPLE)
	WEnd
	SelectDropTroop(0)
	SetLog("Smart Zap Complete.", $COLOR_PURPLE)
	
	Return True
EndFunc

; Checks the value of DE on opponents base. Returns value if there is DE, otherwise returns false.
Func checkDE()
	Local $searchDark, $oldsearchDark, $icount
	If _ColorCheck(_GetPixelColor(30, 142, True), Hex(0x07010D, 6), 10) Then ; check if the village have a Dark Elixir Storage
		$searchDark = ""
		While $searchDark = "" Or $searchDark <> $oldsearchDark
			$oldsearchDark = $searchDark
			$searchDark = getDarkElixirVillageSearch(48, 69 + 57) ; Get updated Dark Elixir value
			$icount += 1
			If $icount > 15 Then ExitLoop ; check couple of times in case troops are blocking image
			If _Sleep(1000) Then Return
		WEnd
		If $debugsetlog = 1 Then Setlog("DE found = " & $searchDark , $COLOR_PURPLE)
		Return $searchDark
	Else
		If $debugsetlog = 1 Then SetLog("No DE Detected.", $COLOR_PURPLE)
		Return False
	EndIf
EndFunc