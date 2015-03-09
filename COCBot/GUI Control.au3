Opt("GUIOnEventMode", 1)
Opt("MouseClickDelay", 10)
Opt("MouseClickDownDelay", 10)
Opt("TrayMenuMode", 3)

_GDIPlus_Startup()

Global Const $64Bit = StringInStr(@OSArch, "64") > 0
Global Const $DEFAULT_HEIGHT = 720
Global Const $DEFAULT_WIDTH = 860
Global $Initiate = 0
Global Const $REGISTRY_KEY_DIRECTORY = "HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0"

Func GUIControl($hWind, $iMsg, $wParam, $lParam)
	Local $nNotifyCode = BitShift($wParam, 16)
	Local $nID = BitAND($wParam, 0x0000FFFF)
	Local $hCtrl = $lParam
	#forceref $hWind, $iMsg, $wParam, $lParam
	Switch $iMsg
		Case 273
			Switch $nID
				Case $GUI_EVENT_CLOSE
					_GDIPlus_Shutdown()
					_GUICtrlRichEdit_Destroy($txtLog)
					SaveConfig()
					Exit
				Case $btnStop
					If $RunState Then btnStop()
				Case $btnHide
					If $RunState Then btnHide()
				Case $cmbTroopComp
					cmbTroopComp()
				Case $chkRequest
					chkRequest()
				Case $tabMain
					tabMain()
				Case $chkMeetGorE
					If GUICtrlRead($chkMeetGorE) = $GUI_CHECKED Then
						GUICtrlSetState($chkMeetGxE, $GUI_UNCHECKED)
					EndIf
				Case $chkMeetGxE
					If GUICtrlRead($chkMeetGxE) = $GUI_CHECKED Then
						GUICtrlSetState($chkMeetGorE, $GUI_UNCHECKED)
					EndIf
			EndSwitch
		Case 274
			Switch $wParam
				Case 0xf060
					_GDIPlus_Shutdown()
					_GUICtrlRichEdit_Destroy($txtLog)
					SaveConfig()
					Exit
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>GUIControl

Func Initiate()
   If IsArray(ControlGetPos($Title, "_ctl.Window", "[CLASS:BlueStacksApp; INSTANCE:1]")) Then
			Local $BSsize = [ControlGetPos($Title, "_ctl.Window", "[CLASS:BlueStacksApp; INSTANCE:1]")[2], ControlGetPos($Title, "_ctl.Window", "[CLASS:BlueStacksApp; INSTANCE:1]")[3]]
			Local $fullScreenRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "FullScreen")
			Local $guestHeightRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "GuestHeight")
			Local $guestWidthRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "GuestWidth")
			Local $windowHeightRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "WindowHeight")
			Local $windowWidthRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "WindowWidth")

	  If $BSsize[0] <> 860 Or $BSsize[1] <> 720 Then
		  RegWrite($REGISTRY_KEY_DIRECTORY, "FullScreen", "REG_DWORD", "0")
		  RegWrite($REGISTRY_KEY_DIRECTORY, "GuestHeight", "REG_DWORD", $DEFAULT_HEIGHT)
		  RegWrite($REGISTRY_KEY_DIRECTORY, "GuestWidth", "REG_DWORD", $DEFAULT_WIDTH)
		  RegWrite($REGISTRY_KEY_DIRECTORY, "WindowHeight", "REG_DWORD", $DEFAULT_HEIGHT)
		  RegWrite($REGISTRY_KEY_DIRECTORY, "WindowWidth", "REG_DWORD", $DEFAULT_WIDTH)
			SetLog("Please restart your computer for the applied changes to take effect.", $COLOR_ORANGE)

			Else
				WinActivate($Title)

				SetLog("~~~~Welcome to " & $sBotTitle & "!~~~~", $COLOR_PURPLE)
				SetLog($Compiled & " running on " & @OSArch & " OS", $COLOR_GREEN)
				SetLog("Bot is starting...", $COLOR_ORANGE)

				$RunState = True
				GUICtrlSetState($cmbBoostBarracks, $GUI_DISABLE)
				GUICtrlSetState($btnLocateBarracks, $GUI_DISABLE)
				GUICtrlSetState($btnSearchMode, $GUI_DISABLE)
				GUICtrlSetState($cmbTroopComp, $GUI_DISABLE)
				GUICtrlSetState($chkBackground, $GUI_DISABLE)
				GUICtrlSetState($btnLocateClanCastle, $GUI_DISABLE)
				GUICtrlSetState($btnLocateTrap, $GUI_DISABLE)
				GUICtrlSetState($btnStart, $GUI_HIDE)
				GUICtrlSetState($btnStop, $GUI_SHOW)
				If GUICtrlRead($txtCapacity) = 0 And $icmbTroopComp <> 8 Then
					 MsgBox(0, "", "Don't Forget to Set Your Troops Capacity in Troop Settings!!")
					 btnStop()
				  EndIf
				runBot()
			EndIf
		Else
			SetLog("Not in Game!", $COLOR_RED)
		 EndIf
   EndFunc
Func Open()
     If $64Bit Then ;If 64-Bit
		 ShellExecute("C:\Program Files (x86)\BlueStacks\HD-StartLauncher.exe")
		 SetLog("Starting BlueStacks", $COLOR_GREEN)
		 Sleep(290)
		  SetLog("Waiting for BlueStacks to initiate...", $COLOR_GREEN)
		 Check()
	  Else ;If 32-Bit
		 ShellExecute("C:\Program Files\BlueStacks\HD-StartLauncher.exe")
		  SetLog("Starting BlueStacks", $COLOR_GREEN)
		 Sleep(290)
		  SetLog("Waiting for BlueStacks to initiate...", $COLOR_GREEN)
		 Check()
   EndIf
EndFunc

Func Check()

   If IsArray(ControlGetPos($Title, "_ctl.Window", "[CLASS:BlueStacksApp; INSTANCE:1]")) Then
	  SetLog("BlueStacks Loaded, took " & ($Initiate) & "seconds." , $COLOR_GREEN)
	  Initiate()
   Else
	  Sleep(1000)
	  $Initiate = $Initiate + 1

	  Check()
   EndIf
EndFunc

Func btnStart()
	CreateLogFile()

	SaveConfig()
	readConfig()
	applyConfig()

	_GUICtrlEdit_SetText($txtLog, "")

	If WinExists($Title) Then
		DisableBS($HWnD, $SC_MINIMIZE)
		DisableBS($HWnD, $SC_CLOSE)
		 Initiate()
	Else
		Open()
	EndIf
EndFunc   ;==>btnStart

Func btnStop()
	If $RunState Then
		$RunState = False
		EnableBS($HWnD, $SC_MINIMIZE)
		EnableBS($HWnD, $SC_CLOSE)
		GUICtrlSetState($btnLocateBarracks, $GUI_ENABLE)
		GUICtrlSetState($btnSearchMode, $GUI_ENABLE)
		GUICtrlSetState($cmbTroopComp, $GUI_ENABLE)
		;GUICtrlSetState($btnLocateCollectors, $GUI_ENABLE)
		GUICtrlSetState($btnLocateClanCastle, $GUI_ENABLE)
		GUICtrlSetState($btnLocateTrap, $GUI_ENABLE)
		GUICtrlSetState($chkBackground, $GUI_ENABLE)
	    GUICtrlSetState($cmbBoostBarracks, $GUI_ENABLE)
		GUICtrlSetState($btnStart, $GUI_SHOW)
		GUICtrlSetState($btnStop, $GUI_HIDE)

		FileClose($hLogFileHandle)
		SetLog("Bot has stopped", $COLOR_ORANGE)
	EndIf
EndFunc   ;==>btnStop

Func btnLocateBarracks()
	$RunState = True
	While 1
		ZoomOut()
		LocateBarrack()
		ExitLoop
	WEnd
	$RunState = False
EndFunc   ;==>btnLocateBarracks

Func btnLocateClanCastle()
	$RunState = True
	While 1
		ZoomOut()
		LocateClanCastle()
		ExitLoop
	WEnd
	$RunState = False
EndFunc   ;==>btnLocateClanCastle

Func btnLocateTrap()
	$RunState = True
	While 1
		ZoomOut()
		LocateTrap()
		ExitLoop
	WEnd
	$RunState = False
EndFunc   ;==>btnLocateTrap

Func btnSearchMode()
	While 1
		GUICtrlSetState($btnStart, $GUI_HIDE)
		GUICtrlSetState($btnStop, $GUI_SHOW)

		GUICtrlSetState($btnLocateBarracks, $GUI_DISABLE)
		GUICtrlSetState($btnSearchMode, $GUI_DISABLE)
		GUICtrlSetState($cmbTroopComp, $GUI_DISABLE)
		GUICtrlSetState($chkBackground, $GUI_DISABLE)
		;GUICtrlSetState($btnLocateCollectors, $GUI_DISABLE)

		$RunState = True
		VillageSearch($TakeAllTownSnapShot)
		$RunState = False

		GUICtrlSetState($btnStart, $GUI_SHOW)
		GUICtrlSetState($btnStop, $GUI_HIDE)

		GUICtrlSetState($btnLocateBarracks, $GUI_ENABLE)
		GUICtrlSetState($btnSearchMode, $GUI_ENABLE)
		GUICtrlSetState($cmbTroopComp, $GUI_ENABLE)
		GUICtrlSetState($chkBackground, $GUI_ENABLE)
		;GUICtrlSetState($btnLocateCollectors, $GUI_ENABLE)
		ExitLoop
	WEnd
EndFunc   ;==>btnSearchMode

Func btnHide()
	If $Hide = False Then
		GUICtrlSetData($btnHide, "Show BS")
		$botPos[0] = WinGetPos($Title)[0]
		$botPos[1] = WinGetPos($Title)[1]
		WinMove($Title, "", -32000, -32000)
		$Hide = True
	Else
		GUICtrlSetData($btnHide, "Hide BS")

		If $botPos[0] = -32000 Then
			WinMove($Title, "", 0, 0)
		Else
			WinMove($Title, "", $botPos[0], $botPos[1])
			WinActivate($Title)
		EndIf
		$Hide = False
	EndIf
EndFunc   ;==>btnHide

Func cmbTroopComp()
	If _GUICtrlComboBox_GetCurSel($cmbTroopComp) <> $icmbTroopComp Then
		$icmbTroopComp = _GUICtrlComboBox_GetCurSel($cmbTroopComp)
		$ArmyComp = 0
		$CurArch = 1
		$CurBarb = 1
		$CurGoblin = 1
		$CurGiant = 1
		$CurWB = 1
		SetComboTroopComp()
	    _GUICtrlComboBox_SetCurSel($cmbAlgorithm, $icmbTroopComp)
	EndIf
EndFunc   ;==>cmbTroopComp

Func SetComboTroopComp()
	Switch _GUICtrlComboBox_GetCurSel($cmbTroopComp)
		Case 0
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_DISABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_DISABLE)

			GUICtrlSetData($txtBarbarians, "0")
			GUICtrlSetData($txtArchers, "100")
			GUICtrlSetData($txtGoblins, "0")

			GUICtrlSetData($txtNumGiants, "0")
			GUICtrlSetData($txtNumWallbreakers, "0")
		Case 1
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_DISABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_DISABLE)

			GUICtrlSetData($txtBarbarians, "100")
			GUICtrlSetData($txtArchers, "0")
			GUICtrlSetData($txtGoblins, "0")

			GUICtrlSetData($txtNumGiants, "0")
			GUICtrlSetData($txtNumWallbreakers, "0")
		Case 2
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_DISABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_DISABLE)

			GUICtrlSetData($txtBarbarians, "0")
			GUICtrlSetData($txtArchers, "0")
			GUICtrlSetData($txtGoblins, "100")

			GUICtrlSetData($txtNumGiants, "0")
			GUICtrlSetData($txtNumWallbreakers, "0")
		Case 3
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_DISABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_DISABLE)

			GUICtrlSetData($txtBarbarians, "50")
			GUICtrlSetData($txtArchers, "50")
			GUICtrlSetData($txtGoblins, "0")

			GUICtrlSetData($txtNumGiants, "0")
			GUICtrlSetData($txtNumWallbreakers, "0")
		Case 4
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_ENABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_DISABLE)

			GUICtrlSetData($txtBarbarians, "60")
			GUICtrlSetData($txtArchers, "30")
			GUICtrlSetData($txtGoblins, "10")

			GUICtrlSetData($txtNumGiants, $GiantsComp)
			GUICtrlSetData($txtNumWallbreakers, "0")
		Case 5
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_ENABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_DISABLE)

			GUICtrlSetData($txtBarbarians, "50")
			GUICtrlSetData($txtArchers, "50")
			GUICtrlSetData($txtGoblins, "0")

			GUICtrlSetData($txtNumGiants, $GiantsComp)
			GUICtrlSetData($txtNumWallbreakers, "0")
		Case 6
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_DISABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_DISABLE)

			GUICtrlSetData($txtBarbarians, "60")
			GUICtrlSetData($txtArchers, "30")
			GUICtrlSetData($txtGoblins, "10")

			GUICtrlSetData($txtNumGiants, "0")
			GUICtrlSetData($txtNumWallbreakers, "0")
		Case 7
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_ENABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_ENABLE)

			GUICtrlSetData($txtBarbarians, "60")
			GUICtrlSetData($txtArchers, "30")
			GUICtrlSetData($txtGoblins, "10")

			GUICtrlSetData($txtNumGiants, $GiantsComp)
			GUICtrlSetData($txtNumWallbreakers, $WBComp)
		Case 8
			GUICtrlSetState($cmbBarrack1, $GUI_ENABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_ENABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_ENABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_ENABLE)
			GUICtrlSetState($txtCapacity, $GUI_DISABLE)
			GUICtrlSetState($txtBarbarians, $GUI_DISABLE)
			GUICtrlSetState($txtArchers, $GUI_DISABLE)
			GUICtrlSetState($txtGoblins, $GUI_DISABLE)
			GUICtrlSetState($txtNumGiants, $GUI_DISABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_DISABLE)
		Case 9
			GUICtrlSetState($cmbBarrack1, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack2, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack3, $GUI_DISABLE)
			GUICtrlSetState($cmbBarrack4, $GUI_DISABLE)
			GUICtrlSetState($txtCapacity, $GUI_ENABLE)
			GUICtrlSetState($txtBarbarians, $GUI_ENABLE)
			GUICtrlSetState($txtArchers, $GUI_ENABLE)
			GUICtrlSetState($txtGoblins, $GUI_ENABLE)
			GUICtrlSetState($txtNumGiants, $GUI_ENABLE)
			GUICtrlSetState($txtNumWallbreakers, $GUI_ENABLE)

			GUICtrlSetData($txtBarbarians, $BarbariansComp)
			GUICtrlSetData($txtArchers, $ArchersComp)
			GUICtrlSetData($txtGoblins, $GoblinsComp)

			GUICtrlSetData($txtNumGiants, $GiantsComp)
			GUICtrlSetData($txtNumWallbreakers, $WBComp)
	EndSwitch
EndFunc   ;==>SetComboTroopComp

Func chkBackground()
	If GUICtrlRead($chkBackground) = $GUI_CHECKED Then
		$ichkBackground = 1
		GUICtrlSetState($btnHide, $GUI_ENABLE)
	Else
		$ichkBackground = 0
		GUICtrlSetState($btnHide, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkBackground

;Func btnLocateCollectors()
;	$RunState = True
;	While 1
;		ZoomOut()
;		LocateCollectors()
;		ExitLoop
;	WEnd
;	$RunState = False
;EndFunc   ;==>btnLocateCollectors

Func chkRequest()
	If GUICtrlRead($chkRequest) = $GUI_CHECKED Then
		$ichkRequest = 1
		GUICtrlSetState($txtRequest, $GUI_ENABLE)
	Else
		$ichkRequest = 0
		GUICtrlSetState($txtRequest, $GUI_DISABLE)
	EndIf
EndFunc

Func tabMain()
	If _GUICtrlTab_GetCurSel($tabMain) = 0 Then
		ControlShow("", "", $txtLog)
	Else
		ControlHide("", "", $txtLog)
	EndIf
EndFunc ;==>tabMain

Func DisableBS($HWnD, $iButton)
	ConsoleWrite('+ Window Handle: ' & $HWnD & @CRLF)
	$hSysMenu = _GUICtrlMenu_GetSystemMenu($HWnD, 0)
	_GUICtrlMenu_RemoveMenu($hSysMenu, $iButton, False)
	_GUICtrlMenu_DrawMenuBar($HWnD)
EndFunc   ;==>DisableBS

Func EnableBS($HWnD, $iButton)
	ConsoleWrite('+ Window Handle: ' & $HWnD & @CRLF)
	$hSysMenu = _GUICtrlMenu_GetSystemMenu($HWnD, 1)
	_GUICtrlMenu_RemoveMenu($hSysMenu, $iButton, False)
	_GUICtrlMenu_DrawMenuBar($HWnD)
EndFunc   ;==>EnableBS

;---------------------------------------------------
If FileExists($config) Then
	readConfig()
	applyConfig()
EndIf

GUIRegisterMsg($WM_COMMAND, "GUIControl")
GUIRegisterMsg($WM_SYSCOMMAND, "GUIControl")
;---------------------------------------------------
