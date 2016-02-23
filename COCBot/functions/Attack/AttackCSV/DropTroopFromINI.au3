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
		;initialize vector arrays
		Local $vectorLetters = StringSplit($vectorString, "-")
		Local $vectorCount = $vectorLetters[0]
		Local $vectors[$vectorCount]
		For $i = 0 To $vectorCount - 1
			$vectors[$i] = Execute("$ATTACKVECTOR_" & $vectorLetters[$i + 1])
		Next
		Local $troopEnum = Eval("e" & $troopName)
		Local $availableTroops = 0
		Local $remainingTroopsDrop = 0
		Local $troopsDropped = 0
		
		For $i = 0 to Ubound($atkTroops) - 1
			If $atkTroops[$i][0] = $troopEnum Then
				$availableTroops = $atkTroops[$i][1]
			EndIf
		Next 
		
		For $i = 0 to Ubound($remainingTroops) - 1
			If $remainingTroops[$i][0] = $troopEnum Then
				$remainingTroopsDrop = $remainingTroops[$i][1]
				;Setlog($remainingTroops[$i][0] & " " & $remainingTroops[$i][1])
			EndIf
		Next

		If $troopEnum = $eKing Or $troopEnum = $eQueen Or $troopEnum = $eWarden Or $troopEnum = $eCastle Then
			$availableTroops = 1
			$remainingTroopsDrop = 1
		EndIf
		
		Setlog($troopName & ": " & $availableTroops & " total, " & $remainingTroopsDrop & " remaining.")
		
		If $isQtyPercent = 1 Then
			Local $qty = Ceiling($availableTroops * ($qtaMin / 100))
		Else
			;Qty to drop
			If $qtaMin <> $qtaMax Then
				Local $qty = Random($qtaMin, $qtaMax, 1)
			Else
				Local $qty = $qtaMin
			EndIf
			
		EndIf
		;SetLog(">> qty to deploy: " & $qty)

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
		;SetLog(">> indexStart: " & $indexStart)
		;SetLog(">> indexEnd: " & $indexEnd)
		
		;number of troop to drop in one point...
		If $qty > 0 and $qty < $indexEnd - $indexStart Then
			;there are less drop doints than indexes
			;spread out the drop points along the indexes
			Local $qtyxpoint = 1
			Local $extraunit = 0
			;Local $indexJump = ($indexEnd - $indexStart) / ($qty + 2)
			Local $indexJump = ($indexEnd - $indexStart) / ($qty - 1)
		Else
			Local $qtyxpoint = Int($qty / ($indexEnd - $indexStart + 1))
			Local $extraunit = Mod($qty, ($indexEnd - $indexStart + 1))
			Local $indexJump = 0
		EndIf
		
		;SetLog(">> qty x point: " & $qtyxpoint)
		;SetLog(">> qty extra: " & $extraunit)
		;SetLog(">> indexJump: " & $indexJump)

		Local $SuspendMode = SuspendAndroid()
		SelectDropTroop($troopPosition) ; select the troop...
		KeepClicks()
		Local $qty2 = $qtyxpoint
		
		;delay time between 2 drops in same point
		If $delayPointmin <> $delayPointmax Then
			Local $delayPoint = Random($delayPointmin, $delayPointmax, 1)
		Else
			Local $delayPoint = $delayPointmin
		EndIf
		
		Local $delayDrop
		
		;drop
		$TroopDropNumber += 1
		;Setlog("$TroopDropNumber = " & $TroopDropNumber)
		$SuspendMode = ResumeAndroid()
		Local $currentJumpIndex
		Local $throttleSpeed = 0

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
				If $troopsDropped >= $availableTroops Then ExitLoop
				
				If $i <= UBound($vectors[$j]) Then
					$pixel = ($vectors[$j])[$i - 1]
					
					If $i < $indexStart + $extraunit Then $qty2 += 1
;Global Enum $eBarb, $eArch, $eGiant, $eGobl, $eWall, $eBall, $eWiza, $eHeal, $eDrag, $ePekk, $eMini, $eHogs, $eValk, $eGole, $eWitc, $eLava, $eKing, $eQueen, $eWarden, $eCastle, $eLSpell, $eHSpell, $eRSpell, $eJSpell, $eFSpell, $ePSpell, $eESpell, $eHaSpell

					If $remainingTroopsDrop = 0 Then ExitLoop
					If $qty2 > $remainingTroopsDrop Then $qty2 = $remainingTroopsDrop
					$remainingTroopsDrop -= $qty2
					$troopsDropped += 1 ;$qty2
				;	$throttleSpeed = 50000
					If $iRadClickSpeedFast = 1 Then
						If $TroopDropNumber = 1 Then
							If $troopsDropped = 1 then
								$throttleSpeed = 20000
							Else
								$throttleSpeed -= 1000
								If $throttleSpeed < 0 Then
									$throttleSpeed = 0
								EndIf
							EndIf
						Else
							$throttleSpeed = 0
						EndIf
					Else
						If $TroopDropNumber = 1 Then
							If $troopsDropped = 1 then
								$throttleSpeed = 40000
							Else
								$throttleSpeed -= 2000
								If $throttleSpeed < 100 Then
									$throttleSpeed = 100
								EndIf
							EndIf
						Else
							$throttleSpeed = 50
						EndIf
					EndIf	
						
						
					Switch $troopEnum
						Case $eBarb To $eLava ; drop normal troops
							;If $debug = True Then
							;	Setlog("Click( " & $pixel[0] & ", " & $pixel[1] & " , " & $qty2 & ", " & $delayPoint & ",#0666)")
							;Else
								FastClick($pixel[0], $pixel[1], $qty2, $throttleSpeed, "#0666")
								;Setlog("SlowClick " & $troopName & ", remaining: " & $remainingTroopsDrop & ", " & $pixel[0] & ", " & $pixel[1] & " , " & $qty2 & ", " & $delayPoint)
								;Click($pixel[0], $pixel[1], $qty2, $delayPoint, "#0666")
							;EndIf
						Case $eKing; drop King
							;If $debug = True Then
							;	Setlog("dropHeroes(" & $pixel[0] & ", " & $pixel[1] & ", " & $King & ", -1, -1) ")
							;Else
								dropHeroes($pixel[0], $pixel[1], $King, -1, -1)
							;EndIf
						Case $eQueen ; drop Queen
							;If $debug = True Then
								Setlog("dropHeroes(" & $pixel[0] & ", " & $pixel[1] & ",-1," & $Queen & ", -1) ")
							;Else
								dropHeroes($pixel[0], $pixel[1],  -1, $Queen , -1)
							;EndIf
						Case $eWarden ; drop Warden
							;If $debug = True Then
							;	Setlog("dropHeroes(" & $pixel[0] & ", " & $pixel[1] & ", -1, -1, " & $Warden & ") ")
							;Else
								dropHeroes($pixel[0], $pixel[1], -1, -1,$Warden)
							;EndIf
						Case $eCastle
							;If $debug = True Then
							;	Setlog("dropCC(" & $pixel[0] & ", " & $pixel[1] & ", " & $CC & ")")
							;Else
								dropCC($pixel[0], $pixel[1], $CC)
							;EndIf
						Case $eLSpell To $eHaSpell
							;If $debug = True Then
							;	Setlog("Drop Spell Click( " & $pixel[0] & ", " & $pixel[1] & " , " & $qty2 & ", " & $delayPoint & ",#0666)")
							;Else
								Click($pixel[0], $pixel[1], $qty2, $delayPoint, "#0667")
							;EndIf
						Case Else
							Setlog("Error parsing line")
					EndSwitch
					;debugAttackCSV("index " & $i & ", vector " & $j & ": " & $troopName & " qty " & $qty2 & " in (" & $pixel[0] & "," & $pixel[1] & ") delay " & $delayPoint)
				EndIf
				If $i <> $indexEnd Then
					;delay time between 2 drops in different point
					If $delayDropMin <> $delayDropMax Then
						$delayDrop = Random($delayDropMin, $delayDropMax, 1)
					Else
						$delayDrop = $delayDropMin
					EndIf
					;debugAttackCSV(">> delay change drop point: " & $delayDrop)
					If $delayDrop <> 0 Then
					    SuspendAndroid($SuspendMode)
						ReleaseClicks()
						If _Sleep($delayDrop) Then
							Return
						EndIf
						KeepClicks()
					EndIf
				EndIf
			Next
		Next
		
		Local $htimerDrop = Round(TimerDiff($hTimer) / 1000, 2)
		Setlog("Dropped " & $troopsDropped & " " & $troopName & " in " & $htimerDrop & " seconds.  Remaining: " & $remainingTroopsDrop)
		
		For $i = 0 to Ubound($remainingTroops) - 1
			If $remainingTroops[$i][0] = $troopEnum Then
				$remainingTroops[$i][1] = $remainingTroopsDrop
			EndIf
		Next 

	    ReleaseClicks()
	    SuspendAndroid($SuspendMode)

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
