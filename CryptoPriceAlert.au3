#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=CryptoPriceAlert.ico
#AutoIt3Wrapper_Res_Icon_Add=DownArrow.ico
#AutoIt3Wrapper_Res_Icon_Add=UpArrow.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=Cryptocurrency Price Alerts
#AutoIt3Wrapper_Res_Fileversion=1.0
#AutoIt3Wrapper_Res_LegalCopyright=ImmortalTools
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Field=Made By|ImmortalTools
#AutoIt3Wrapper_Res_File_Add=ImmortalTools Logo.png, rt_rcdata, ImmortalTools Logo.png
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------

	AutoIt Version:...3.3.8.1
	Author:...........ImmortalTools

	Version:...1.0
	Changes:...first release

#ce ----------------------------------------------------------------------------


#include "Constants.au3"	;Global constants has been added to Constants.au3
;Library files from default AutoIT include folder and external UDF:
 ;Functions needed has been included in the file Library.au3,
 ;for less file size and less memory usage.
#include "Library.au3"

Opt("TrayMenuMode", 1)	; No default tray menu
AdlibRegister("UpdatePrice", 60*1000) ; Update price every 60 seconds


;Set global variables for settings
Global $Version = "1.0"
Global $ConfigFile = @AppDataDir&"/ImmortalTools/CryptoPriceAlert.ini"
Global $CheckForUpdateOnStartup = IniRead($ConfigFile, "SETTINGS", "CheckForUpdate", "1")
Global $PosX = IniRead($ConfigFile, "SETTINGS", "PosX", (@DesktopWidth/2)-105) ;Get position or set to middle of width
Global $PosY = IniRead($ConfigFile, "SETTINGS", "PosY", (@DesktopHeight)-61) ;Get position or set to above taskbar
Global $Size = IniRead($ConfigFile, "SETTINGS", "Size", "Medium")
Global $Transparency = IniRead($ConfigFile, "SETTINGS", "Transparency", "255")
Global $ClickThrough = IniRead($ConfigFile, "SETTINGS", "ClickThrough", "0")

TrayMenu() ;Create menu for the task tray
Main() ;Run main application


Func TrayMenu()
	;Create a tray menu sub menu with tree sub items.
	Global $iSize = TrayCreateMenu("Size")
    Global $iLargeSize = TrayCreateItem("Large", $iSize)
    Global $iMediumSize = TrayCreateItem("Medium", $iSize)
	Global $iSmallSize = TrayCreateItem("Small", $iSize)
	If $Size = "Large" Then TrayItemSetState($iLargeSize, $TRAY_CHECKED)
	If $Size = "Medium" Then TrayItemSetState($iMediumSize, $TRAY_CHECKED)
	If $Size = "Small" Then TrayItemSetState($iSmallSize, $TRAY_CHECKED)

	;Add more settings and set current state.
	Global $iTransparent = TrayCreateItem("Transparent")
	If $Transparency <> "255" Then TrayItemSetState($iTransparent, $TRAY_CHECKED)
	Global $iClickThrough = TrayCreateItem("Click Through")
	If $ClickThrough = "1" Then TrayItemSetState($iClickThrough, $TRAY_CHECKED)
	Global $iCheckForUpdateOnStartup = TrayCreateItem("Check for update on startup")
	If $CheckForUpdateOnStartup = "1" Then TrayItemSetState($iCheckForUpdateOnStartup, $TRAY_CHECKED)
    TrayCreateItem("") ; Create a separator line.

	Global $iCheckForUpdate = TrayCreateItem("Check for update")
    Global $idAbout = TrayCreateItem("About")
    TrayCreateItem("") ; Create a separator line.

    Global $idExit = TrayCreateItem("Exit")
    TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.
EndFunc   ;==>TrayMenu


Func Main()
	;Create notification gui
	$GUI = GUICreate("CryptoPriceAlert", 210, 30, $PosX, $PosY, $WS_POPUP + $WS_BORDER, $WS_EX_TOPMOST + $WS_EX_TOOLWINDOW)
	GUISetFont(14)
	If $Size = "Large" Then
		WinMove($GUI, "", $PosX, $PosY, 300, 40)
		GUISetFont(20)
		Local $SizeDiff = 0
	ElseIf $Size = "Small" Then
		WinMove($GUI, "", $PosX, $PosY, 150, 27)
		GUISetFont(10)
		Local $SizeDiff = 77
	Else
		$SizeDiff = 45
	EndIf
	GUICtrlCreateLabel("DOGE/BTC:", 5, 5, 146 - $SizeDiff)
	Global $DogeBtcPrice = GUICtrlCreateLabel("", 155  - $SizeDiff, 5, 200 - $SizeDiff, 30)
	GUISetState(@SW_SHOW)
	If $CheckForUpdateOnStartup = "1" Then CheckForUpdate()
	UpdatePrice()
	WinSetTrans($GUI, "", $Transparency)
	If $ClickThrough="1" Then _WinAPI_SetWindowLong($GUI, $GWL_EXSTYLE, BitOR(_WinAPI_GetWindowLong($GUI, $GWL_EXSTYLE), $WS_EX_TRANSPARENT))

	While 1
		$msg = GUIGetMsg()
		Switch $msg
			;Make window movable
			Case $GUI_EVENT_PRIMARYDOWN
				_SendMessage($GUI, $WM_SYSCOMMAND, 0xF012, 0)
			;Save position changes
			Case $GUI_EVENT_PRIMARYUP
				$WinPos=WinGetPos($GUI)
				$PosX=$WinPos[0]
				$PosY=$WinPos[1]
				IniWrite($ConfigFile, "SETTINGS", "PosX", $PosX)
				IniWrite($ConfigFile, "SETTINGS", "PosY", $PosY)
			Case $GUI_EVENT_CLOSE
				Exit
		EndSwitch

		Switch TrayGetMsg()
			Case $iLargeSize ;Set and save large size
				TrayItemSetState($iMediumSize, $TRAY_UNCHECKED)
				TrayItemSetState($iSmallSize, $TRAY_UNCHECKED)
				IniWrite($ConfigFile, "SETTINGS", "Size", "Large")
				$Size="Large"
				GUIDelete($GUI)
				Main()
			Case $iMediumSize ;Set and save medium size
				TrayItemSetState($iLargeSize, $TRAY_UNCHECKED)
				TrayItemSetState($iSmallSize, $TRAY_UNCHECKED)
				IniWrite($ConfigFile, "SETTINGS", "Size", "Medium")
				$Size="Medium"
				GUIDelete($GUI)
				Main()
			Case $iSmallSize ;Set and save small size
				TrayItemSetState($iLargeSize, $TRAY_UNCHECKED)
				TrayItemSetState($iMediumSize, $TRAY_UNCHECKED)
				IniWrite($ConfigFile, "SETTINGS", "Size", "Small")
				$Size="Small"
				GUIDelete($GUI)
				Main()
			Case $iTransparent
				If BitAND(TrayItemGetState($iTransparent), $TRAY_CHECKED) = $TRAY_CHECKED Then ;Enable transparency
					WinSetTrans($GUI, "", "160")
					IniWrite($ConfigFile, "SETTINGS", "Transparency", "160")
					TrayItemSetState($iTransparent, $TRAY_CHECKED)
					$Transparency = "160"
				Else ;Disable transparency
					WinSetTrans($GUI, "", "255")
					IniWrite($ConfigFile, "SETTINGS", "Transparency", "255")
					TrayItemSetState($iTransparent, $TRAY_UNCHECKED)
					$Transparency = "255"
				EndIf
			Case $iClickThrough
				If BitAND(TrayItemGetState($iClickThrough), $TRAY_CHECKED) = $TRAY_CHECKED Then ;Enable click through
					_WinAPI_SetWindowLong($GUI, $GWL_EXSTYLE, BitOR(_WinAPI_GetWindowLong($GUI, $GWL_EXSTYLE), $WS_EX_TRANSPARENT))
					IniWrite($ConfigFile, "SETTINGS", "ClickThrough", "1")
					TrayItemSetState($iClickThrough, $TRAY_CHECKED)
					$ClickThrough = "1"
				Else ;Disable click through
					Local $NoTrans = BitNOT($WS_EX_TRANSPARENT)
					_WinAPI_SetWindowLong($GUI, $GWL_EXSTYLE, BitAND(_WinAPI_GetWindowLong($GUI, $GWL_EXSTYLE), $NoTrans))
					IniWrite($ConfigFile, "SETTINGS", "ClickThrough", "0")
					TrayItemSetState($iClickThrough, $TRAY_UNCHECKED)
					$ClickThrough = "0"
				EndIf
			Case $iCheckForUpdateOnStartup
				If BitAND(TrayItemGetState($iCheckForUpdateOnStartup), $TRAY_CHECKED) = $TRAY_CHECKED Then ;Enable check for update
					IniWrite($ConfigFile, "SETTINGS", "CheckForUpdate", "1")
					TrayItemSetState($iCheckForUpdateOnStartup, $TRAY_CHECKED)
					$ClickThrough = "1"
				Else ;Disable check for update
					IniWrite($ConfigFile, "SETTINGS", "CheckForUpdate", "0")
					TrayItemSetState($iCheckForUpdateOnStartup, $TRAY_UNCHECKED)
					$ClickThrough = "0"
				EndIf
			Case $iCheckForUpdate
				CheckForUpdate()
				TrayItemSetState($iCheckForUpdate, $TRAY_UNCHECKED)
			Case $idAbout ;Display the about gui
				AboutGUI()
				TrayItemSetState($idAbout, $TRAY_UNCHECKED)
			Case $idExit ;Exit the program
				Exit
		EndSwitch
	WEnd
EndFunc


Func UpdatePrice()
	Local $CryptoPrice
	Local $PriceStatus
	GUISetCursor(15, 1)

	;Get price and positive/negative change from innertext on coinmarketcap
	Local $InnerText=_INetGetSource("http://coinmarketcap.com/currencies/dogecoin/", True)

	If StringInStr($InnerText, "positive_change") Then
		$CryptoPrice=StringSplit($InnerText, ' BTC</small>  <small class=" positive_change', 1)
		$PriceStatus=2
	ElseIf StringInStr($InnerText, "negative_change") Then
		$CryptoPrice=StringSplit($InnerText, ' BTC</small>  <small class=" negative_change', 1)
		$PriceStatus=1
	EndIf

	If IsArray($CryptoPrice) Then
		If UBound($CryptoPrice, $UBOUND_ROWS)=3 Then
			If StringLeft($CryptoPrice[2], 8)=" 0.00 %" Then Local $PriceStatus=0
			$CryptoPrice=StringRight($CryptoPrice[1], 10)
			;show percentage: $CryptoPrice=StringRight($CryptoPrice[1], 10)&StringLeft($CryptoPrice[2], 8)
		Else
			$CryptoPrice="ERROR"
		Endif
	Else
		$CryptoPrice="ERROR"
		$PriceStatus=1
	EndIf

	;Set price in gui
	GUICtrlSetData($DogeBtcPrice, $CryptoPrice)
	If $PriceStatus = 0 Then
		GUICtrlSetColor($DogeBtcPrice, $COLOR_BLUE)
		TraySetIcon(@ScriptFullPath, -6) ;Change Icon! -6 is green up arrow
	ElseIf $PriceStatus=1 Then
		GUICtrlSetColor($DogeBtcPrice, $COLOR_RED)
		TraySetIcon(@ScriptFullPath, -5) ;Change Icon! -6 is green up arrow
	ElseIf $PriceStatus = 2 Then
		GUICtrlSetColor($DogeBtcPrice, $COLOR_GREEN)
		TraySetIcon(@ScriptFullPath, -6) ;Change Icon! -6 is green up arrow
	EndIf
	$PrevPrice=$CryptoPrice

	GUISetCursor(2)
EndFunc


Func CheckForUpdate()
	;Set update status in gui.
	GUISetCursor(15, 1)
	Local $UpdateLabel = GUICtrlCreateLabel("Checking for update", 5, 5, 300)

	;read current version info from server.
	Local $CheckForUpdate = _INetGetSource("http://immortaltools.com/CheckForUpdate/CryptoPriceAlert_CheckForUpdate.txt")
	;Split the string and seperate version and update url.
	$CheckForUpdate = StringSplit(StringStripWS(StringStripCR($CheckForUpdate), 4), " " & @LF)
	If IsArray($CheckForUpdate) Then
		Local $UpdateCheck = $CheckForUpdate[1]
		If UBound($CheckForUpdate, $UBOUND_ROWS)=3 Then
			Local $UpdateURL = $CheckForUpdate[2]
		Else
			$UpdateURL = ""
		EndIf
	Else
		$Update = MsgBox(262144 + 4 + 16, "Error!", "Could not check for update! " & @CRLF & "Would you like to check manually?")
		If $Update = 6 Then
			ShellExecute("http://www.immortaltools.com")
		EndIf
		GUICtrlDelete($UpdateLabel)
		Return
	EndIf

	;Check if there is a newer version and ask user to update if there is.
	If $UpdateCheck > $Version Then
		$Update = MsgBox(262144 + 4 + 64, "CryptoPriceAlert " & $Version, "An update is available! Would you like to update now?", 20)
		If $Update = 6 Then
			If $UpdateURL <> "E" And $UpdateURL <> "" Then
				ShellExecute($UpdateURL)
			Else
				ShellExecute("http://www.immortaltools.com")
			EndIf
		EndIf
	EndIf
	GUICtrlDelete($UpdateLabel)
EndFunc   ;==>CheckForUpdate


Func AboutGUI()
	$AboutGUI = GUICreate("About CryptoPriceAlert", 425, 200, -1, -1, $WS_SYSMENU, $WS_EX_TOPMOST)
	$Group1 = GUICtrlCreateGroup("", 8, 0, 404, 165) ;Create a border line

	;Load the picture from resources and position in gui
	GUICtrlCreatePic(@ScriptDir & "\ImmortalTools Logo.png", 20, 20)
	$Image = _GUICtrlPic_Create(@ScriptDir & "\ImmortalTools Logo.png", 20, 20, 380, 85, BitOR($SS_CENTERIMAGE, $SS_NOTIFY), Default)
	_ResourceSetImageToCtrl($Image, "ImmortalTools Logo.png")

	;Add details about the program
	$Label1 = GUICtrlCreateLabel("Version: " & $Version, 16, 130, 105, 17)
	$Label2 = GUICtrlCreateLabel("Copyright © 2014 ImmortalTools", 95, 130, 170, 17)
	$Label3 = GUICtrlCreateLabel("Click here for other tools: ", 16, 145, 120, 17)

	;Add hyperlinks for website and donation, and add donation picture from resources
	$URL1 = _GuiCtrlCreateHyperlink("ImmortalTools", 140, 145, 67, 17, 0x0000ff)
	$URL2 = _GuiCtrlCreateHyperlink("", 270, 113, 113, 46, 0x0000ff)
	$DonationImage = _GUICtrlPic_Create(@ScriptDir & "\Paypal Donate.png", 270, 113, 113, 46, BitOR($SS_CENTERIMAGE, $SS_NOTIFY), Default)
	_ResourceSetImageToCtrl($DonationImage, "Paypal Donate.png")

	GUISetState(@SW_SHOW)
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE ;Close gui
				GUIDelete($AboutGUI)
				ExitLoop
			Case $URL1 ;open url to website
				ShellExecute("http://immortaltools.com")
				GUIDelete($AboutGUI)
				ExitLoop
			Case $URL2 ;open donation url
				ShellExecute("http://immortaltools.com/donate")
				GUIDelete($AboutGUI)
				ExitLoop
		EndSwitch
	WEnd
EndFunc   ;==>AboutGUI