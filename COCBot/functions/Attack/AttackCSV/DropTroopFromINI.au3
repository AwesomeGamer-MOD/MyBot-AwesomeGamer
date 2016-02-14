; #FUNCTION# ====================================================================================================================
; Name ..........: DropTroopFromINI
; Description ...:
; Syntax ........: DropTroopFromINI($vectors, $indexStart, $indexEnd, $qtaMin, $qtaMax, $troopName, $delayPointmin,
;                  $delayPointmax, $delayDropMin, $delayDropMax, $sleepafterMin, $sleepAfterMax[, $debug = False])
; Parameters ....: $vectors             -
;                  $indexStart          -
;                  $indexEnd            -
;                  $qtaMin              -
;                  $qtaMax              -
;                  $troopName           -
;                  $delayPointmin       -
;                  $delayPointmax       -
;                  $delayDropMin        -
;                  $delayDropMax        -
;                  $sleepafterMin       -
;                  $sleepAfterMax       -
;                  $debug               - [optional] Default is False.
; Return values .: None
; Author ........: Sardo (2016)
; Modified ......: AwesomeGamer (Feb. 11th 2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func DropTroopFromINI($vectorString, $indexStart, $indexEnd, $qtaMin, $qtaMax, $troopName, $delayPointmin, $delayPointmax, $delayDropMin, $delayDropMax, $sleepafterMin, $sleepAfterMax, $isQtyPercent, $isIndexPercent, $debug = False)
	debugAttackCSV("drop using vectors " & $vectorString & " index " & $indexStart & "-" & $indexEnd & " and using " & $qtaMin & "-" & $qtaMax & " of " & $troopName)
	debugAttackCSV(" - delay for multiple troops in same point: " & $delayPointmin & "-" & $delayPointmax)
	debugAttackCSV(" - delay when  change deploy point : " & $delayDropMin & "-" & $delayDropMax)
	debugAttackCSV(" - delay after drop all troops : " & $sleepafterMin & "-" & $sleepAfterMax)

	;initialize vector arrays
	Local $vectorLetters = StringSplit($vectorString, "-")
	Local $vectorCount = $vectorLetters[0]
	Local $vectors[$vectorCount]
	For $i = 0 To $vectorCount - 1
		$vectors[$i] = Execute("$ATTACKVECTOR_" & $vectorLetters[$i + 1])
	Next
	Local $troopEnum = Eval("e" & $troopName)
	Local $availableTroops = 0
	
	If $isQtyPercent = 1 Then
		For $i = 0 to Ubound($atkTroops) - 1
			If $atkTroops[$i][0] = $troopEnum Then
				$availableTroops = $atkTroops[$i][1]
			EndIf
		Next
		Local $qty = Ceiling($availableTroops * ($qtaMin / 100))
	Else
		;Qty to drop
		If $qtaMin <> $qtaMax Then
			Local $qty = Random($qtaMin, $qtaMax, 1)
		Else
			Local $qty = $qtaMin
		EndIf
		
	EndIf
	debugAttackCSV(">> qty to deploy: " & $qty)

	Local $minSize = 1000
	For $i = 0 To $vectorCount - 1
		If Ubound($vectors[$i]) < $minSize Then $minSize = Ubound($vectors[$i])
		debugAttackCSV(">> vector " & $i & "=" & Ubound($vectors[$i]))
	Next
	debugAttackCSV(">> minSize " & "=" & $minSize)
	If $isIndexPercent = 1 Then
		$indexStart = Floor($minSize * ($indexStart / 100))
		$indexEnd = Ceiling($minSize * ($indexEnd / 100))
		if $indexStart = 0 then
			$indexStart = 1
		EndIf
	EndIf
	debugAttackCSV(">> indexStart: " & $indexStart)
	debugAttackCSV(">> indexEnd: " & $indexEnd)
	
	;number of troop to drop in one point...
	If $qty > 0 and $qty < $indexEnd - $indexStart Then
		;there are less drop doints than indexes
		;spread out the drop points along the indexes
		Local $qtyxpoint = 1
		Local $extraunit = 0
		;Local $indexJump = ($indexEnd - $indexStart) / ($qty + 2)
		Local $indexJump = ($indexEnd - $indexStart) / ($qty)
	Else
		Local $qtyxpoint = Int($qty / ($indexEnd - $indexStart + 1))
		Local $extraunit = Mod($qty, ($indexEnd - $indexStart + 1))
		Local $indexJump = 0
	EndIf
	
	debugAttackCSV(">> qty x point: " & $qtyxpoint)
	debugAttackCSV(">> qty extra: " & $extraunit)
	debugAttackCSV(">> indexJump: " & $indexJump)
	;search slot where is the troop...
	Local $troopPosition = -1
	For $i = 0 To UBound($atkTroops) - 1
		If $atkTroops[$i][0] = Eval("e" & $troopName) Then
			$troopPosition = $i
		EndIf
	Next

	Local $usespell = True
	Switch Eval("e" & $troopName)
		Case $eLSpell
			If $ichkLightSpell[$iMatchMode] = 0 Then $usespell = False
		Case $eHSpell
			If $ichkHealSpell[$iMatchMode] = 0 Then $usespell = False
		Case $eRSpell
			If $ichkRageSpell[$iMatchMode] = 0 Then $usespell = False
		Case $eJSpell
			If $ichkJumpSpell[$iMatchMode] = 0 Then $usespell = False
		Case $eFSpell
			If $ichkFreezeSpell[$iMatchMode] = 0 Then $usespell = False
		Case $ePSpell
			If $ichkPoisonSpell[$iMatchMode] = 0 Then $usespell = False
		Case $eESpell
			If $ichkEarthquakeSpell[$iMatchMode] = 0 Then $usespell = False
		Case $eHaSpell
			If $ichkHasteSpell[$iMatchMode] = 0 Then $usespell = False
	EndSwitch

	If $troopPosition = -1 Or $usespell = False Then
		If $usespell = True Then
			;Setlog("No troop found in your attack troops list")
			debugAttackCSV("No troop found in your attack troops list")
		Else
			If $DebugSetLog = 1 Then SetLog("discard use spell", $COLOR_PURPLE)
		EndIf

	Else
		SelectDropTroop($troopPosition) ; select the troop...
		
		Local $qty2 = $qtyxpoint
		
		;delay time between 2 drops in same point
		If $delayPointmin <> $delayPointmax Then
			Local $delayPoint = Random($delayPointmin, $delayPointmax, 1)
		Else
			Local $delayPoint = $delayPointmin
		EndIf
		
		Local $delayDrop
		
		;drop
		Local $currentJumpIndex

		Local $hTimer = TimerInit()
		For $i = $indexStart To $indexEnd
			If $indexJump > 0 Then
				;check to see if we skip this index to spread out troops
				if $i = $indexStart Then
					$currentJumpIndex = $indexStart + $indexJump
				ElseIf $i = Round($currentJumpIndex) Then
					$currentJumpIndex += $indexJump
				Else
					ContinueLoop
				EndIf
			EndIf
			
			For $j = 0 To $vectorCount - 1
				If $i <= UBound($vectors[$j]) Then
					$pixel = ($vectors[$j])[$i - 1]
					
					If $i < $indexStart + $extraunit Then $qty2 += 1

					Switch $troopEnum
						Case $eBarb To $eArch ; drop normal troops
							If $debug = True Then
								Setlog("Click( " & $pixel[0] & ", " & $pixel[1] & " , " & $qty2 & ", " & $delayPoint & ",#0666)")
							Else
								PureClick($pixel[0], $pixel[1], $qty2, $delayPoint, "#0666")
							EndIf
						Case $eGiant To $eLava
							If $debug = True Then
								Setlog("Click( " & $pixel[0] & ", " & $pixel[1] & " , " & $qty2 & ", " & $delayPoint & ",#0666)")
							Else
								Click($pixel[0], $pixel[1], $qty2, $delayPoint, "#0666")
							EndIf
						Case $eKing; drop King
							If $debug = True Then
								Setlog("dropHeroes(" & $pixel[0] & ", " & $pixel[1] & ", " & $King & ", -1, -1) ")
							Else
								dropHeroes($pixel[0], $pixel[1], $King, -1, -1)
							EndIf
						Case $eQueen ; drop Queen
							If $debug = True Then
								Setlog("dropHeroes(" & $pixel[0] & ", " & $pixel[1] & ", -1, " & $Queen & ", -1) ")
							Else
								dropHeroes($pixel[0], $pixel[1], -1, $Queen, -1)
							EndIf
						Case $eWarden ; drop Warden
							If $debug = True Then
								Setlog("dropHeroes(" & $pixel[0] & ", " & $pixel[1] & ", -1, -1, " & $Warden & ") ")
							Else
								dropHeroes($pixel[0], $pixel[1], -1, -1, $Warden)
							EndIf
						Case $eCastle
							If $debug = True Then
								Setlog("dropCC(" & $pixel[0] & ", " & $pixel[1] & ", " & $CC & ")")
							Else
								dropCC($pixel[0], $pixel[1], $CC)
							EndIf
						Case $eLSpell To $eHaSpell
							If $debug = True Then
								Setlog("Drop Spell Click( " & $pixel[0] & ", " & $pixel[1] & " , " & $qty2 & ", " & $delayPoint & ",#0666)")
							Else
								Click($pixel[0], $pixel[1], $qty2, $delayPoint, "#0667")
							EndIf
						Case Else
							Setlog("Error parsing line")
					EndSwitch
					debugAttackCSV("index " & $i & ", vector " & $j & ": " & $troopName & " qty " & $qty2 & " in (" & $pixel[0] & "," & $pixel[1] & ") delay " & $delayPoint)
				EndIf
				If $i <> $indexEnd Then
					;delay time between 2 drops in different point
					If $delayDropMin <> $delayDropMax Then
						$delayDrop = Random($delayDropMin, $delayDropMax, 1)
					Else
						$delayDrop = $delayDropMin
					EndIf
					debugAttackCSV(">> delay change drop point: " & $delayDrop)
					If $delayDrop <> 0 Then
						If _Sleep($delayDrop) Then Return
					EndIf
				EndIf
			Next
		Next
		
		Local $htimerDrop = Round(TimerDiff($hTimer) / 1000, 2)
		Setlog($troopName & " drop took " & $htimerDrop & " seconds.")

		;sleep time after deploy all troops
		If $sleepafterMin <> $sleepAfterMax Then
			Local $sleepafter = Random($sleepafterMin, $sleepAfterMax, 1)
		Else
			Local $sleepafter = $sleepafterMin
		EndIf
		debugAttackCSV(">> delay after drop all troops: " & $sleepafter)
		If $sleepafter <> 0 Then
			If _Sleep($sleepafter) Then Return
		EndIf
	EndIf

EndFunc   ;==>DropTroopFromINI
