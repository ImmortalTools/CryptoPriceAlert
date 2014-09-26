#cs ----------------------------------------------------------------------------

	Library for:...CryptoPriceAlert
	From:..........Default Autoit Include files and external UDF

	Version:...1
	Changes:...first release

#ce ----------------------------------------------------------------------------


;Create hyperlink in GUI
Func _GuiCtrlCreateHyperlink($s_Text, $i_Left, $i_Top, $i_Width = -1, $i_Height = -1, $i_Color = 0x0000ff, $s_ToolTip = '', $i_Style = -1, $i_ExStyle = -1)
	Local $i_CtrlID
	$i_CtrlID = GUICtrlCreateLabel($s_Text, $i_Left, $i_Top, $i_Width, $i_Height, $i_Style, $i_ExStyle)
	If $i_CtrlID <> 0 Then
		GUICtrlSetFont($i_CtrlID, -1, -1, 4)
		GUICtrlSetColor($i_CtrlID, $i_Color)
		GUICtrlSetCursor($i_CtrlID, 0)
	EndIf
	Return $i_CtrlID
EndFunc   ;==>_GuiCtrlCreateHyperlink


; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_Create
; Description ...: Pic-Control für alle von GDIPlus unterstützten Formate ggf. mit Transparenz erstellen.
; Syntax.........: _GUICtrlPic_Create($sPicPath, $iLeft, $iTop[, $iWidth = 0[, $iHeight = 0[, $uStyles = -1[, $uExStyles = -1[, $bKeepAspectRatio = False]]]]])
; Parameters ....: Die Parameter entsprechen bis auf den letzten der AU3-Funktion GUICtrlCreatePic()
;                  $bKeepAspectRatio - Seitenverhältnis bei der Größenanpassung beachten:
;                  |True    - ja
;                  |False   - nein
;                  |Default - nein
; Return values .: Im Erfolgsfall: ControlID aus GUICtrlCreatePic()
;                  Im Fehlerfall: False, @error und @extended enthalten ergänzende fehlerbeschreibende Werte.
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_Create($sPicPath, $iLeft, $iTop, $iWidth = 0, $iHeight = 0, $uStyles = -1, $uExStyles = -1, $bKeepAspectRatio = False)
	Local Const $IMAGE_BITMAP = 0x0000
	Local Const $STM_SETIMAGE = 0x0172
	Local $aResult, $hBitmap, $hImage, $Height, $Width, $CtrlID
	Local $aBitmap = _GUICtrlPic_LoadImage($sPicPath)
	If @error Then Return SetError(@error, @extended, False)
	$hBitmap = $aBitmap[0]
	$Width = $aBitmap[1]
	$Height = $aBitmap[2]
	If $iWidth = 0 And $iHeight = 0 Then
		$iWidth = $Width
		$iHeight = $Height
	Else
		$hBitmap = _GUICtrlPic_ScaleBitmap($hBitmap, $iWidth, $iHeight, $Width, $Height, $bKeepAspectRatio)
		If @error Then Return SetError(@error, @extended, False)
	EndIf
	$CtrlID = GUICtrlCreatePic("", $iLeft, $iTop, $iWidth, $iHeight, $uStyles, $uExStyles)
	GUICtrlSendMsg($CtrlID, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
	DllCall("Gdi32.dll", "BOOL", "DeleteObject", "Handle", $hBitmap)
	Return $CtrlID
EndFunc   ;==>_GUICtrlPic_Create


; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_LoadImage
; Description ...: Bilddatei laden und HBITMAP erzeugen
; Syntax.........: _GUICtrlPic_LoadImage($sPicPath)
; Parameters ....: $sPicPath         - vollständiger Pfad der Bilddatei
; Return values .: Im Erfolgsfall: Array mit drei Einträgen, Array[0] enthält ein HBITMAP-Handle,
;                                  Array[1] die Breite und Array[2] die Höhe der Bitmap
;                  Im Fehlerfall: False, @error und @extended enthalten ggf. ergänzende fehlerbeschreibende Werte
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......: Die Funktion kann auch einzeln genutzt werden, um eine Bitmap zu laden und dann per
;                  GUICtrlSendMsg($idPIC, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap) einem Pic-Control zuzuweisen.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_LoadImage($sPicPath)
	Local $aResult, $hBitmap, $hImage, $Height, $Width
	Local $aBitmap[3] = [0, 0, 0]
	Local $hGDIPDll = DllOpen("GDIPlus.dll")
	If $hGDIPDll = -1 Then Return SetError(1, 2, $aBitmap)
	Local $tInput = DllStructCreate("UINT Version;ptr Callback;BOOL NoThread;BOOL NoCodecs")
	Local $pInput = DllStructGetPtr($tInput)
	Local $tToken = DllStructCreate("ULONG_PTR Data")
	Local $pToken = DllStructGetPtr($tToken)
	DllStructSetData($tInput, "Version", 1)
	$aResult = DllCall($hGDIPDll, "INT", "GdiplusStartup", "Ptr", $pToken, "Ptr", $pInput, "Ptr", 0)
	If @error Then Return SetError(@error, @extended, $aBitmap)
	$aResult = DllCall($hGDIPDll, "INT", "GdipLoadImageFromFile", "WStr", $sPicPath, "Ptr*", 0)
	If @error Or $aResult[2] = 0 Then
		Local $Error = @error, $Extended = @extended
		DllCall($hGDIPDll, "None", "GdiplusShutdown", "Ptr", DllStructGetData($tToken, "Data"))
		DllClose($hGDIPDll)
		Return SetError($Error, $Extended, $aBitmap)
	EndIf
	$hImage = $aResult[2]
	$aResult = DllCall($hGDIPDll, "INT", "GdipGetImageWidth", "Handle", $hImage, "UINT*", 0)
	$Width = $aResult[2]
	$aResult = DllCall($hGDIPDll, "INT", "GdipGetImageHeight", "Handle", $hImage, "UINT*", 0)
	$Height = $aResult[2]
	$aResult = DllCall($hGDIPDll, "INT", "GdipCreateHBITMAPFromBitmap", "Handle", $hImage, "Ptr*", 0, "DWORD", 0xFF000000)
	$hBitmap = $aResult[2]
	DllCall($hGDIPDll, "INT", "GdipDisposeImage", "Handle", $hImage)
	DllCall($hGDIPDll, "None", "GdiplusShutdown", "Ptr", DllStructGetData($tToken, "Data"))
	DllClose($hGDIPDll)
	$aBitmap[0] = $hBitmap
	$aBitmap[1] = $Width
	$aBitmap[2] = $Height
	Return $aBitmap
EndFunc   ;==>_GUICtrlPic_LoadImage


; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_ScaleBitmap
; Description ...: Geladene Bitmap skalieren.
; Syntax.........: _GUICtrlPic_ScaleBitmap($hBitmap, $iNewW, $iNewH[, $iBitmapW[, $iBitmapH[, $bKeepAspectRatio = False]]])
; Parameters ....: $hBitmap          - HBITMAP-Handle
;                  $iNewW            - gewünschte Breite in Pixeln
;                  $iNewH            - gewünschte Höhe in Pixeln
;                  $iBitmapW         - aktuelle Breite der Bitmap (wird nur für das Skalieren im Seitenverhältnis benötigt
;                  $iBitmapH         - aktuelle Höhe der Bitmap (wird nur für das Skalieren im Seitenverhältnis benötigt
;                  $bKeepAspectRatio - Seitenverhältnis bei der Größenanpassung beachten:
;                  |True    - ja
;                  |False   - nein
;                  |Default - nein
; Return values .: Im Erfolgsfall: HBITMAP-Handle für die skalierte Bitmap
;                  Im Fehlerfall: False, @error und @extended enthalten ggf. ergänzende fehlerbeschreibende Werte
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......: Die Funktion kann auch einzeln genutzt werden, um eine Bitmap zu skalieren und dann per
;                  GUICtrlSendMsg($idPIC, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap) einem Pic-Control zuzuweisen.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_ScaleBitmap($hBitmap, $iNewW, $iNewH, $iBitmapW, $iBitmapH, $bKeepAspectRatio = False)
	Local Const $IMAGE_BITMAP = 0x0000
	If $bKeepAspectRatio Then
		If $iBitmapW >= $iBitmapH Then
			$iBitmapH *= $iNewW / $iBitmapW
			$iBitmapW = $iNewW
			If $iBitmapH > $iNewH Then
				$iBitmapW *= $iNewH / $iBitmapH
				$iBitmapH = $iNewH
			EndIf
		Else
			$iBitmapW *= $iNewH / $iBitmapH
			$iBitmapH = $iNewH
			If $iBitmapW > $iNewW Then
				$iBitmapH *= $iNewW / $iBitmapW
				$iBitmapW = $iNewW
			EndIf
		EndIf
	Else
		$iBitmapW = $iNewW
		$iBitmapH = $iNewH
	EndIf
	Local $aResult = DllCall("User32.dll", "Handle", "CopyImage", _
			"Handle", $hBitmap, "UINT", $IMAGE_BITMAP, "INT", $iBitmapW, "INT", $iBitmapH, "UINT", 0x4 + 0x8)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlPic_ScaleBitmap


Func _ResourceSetImageToCtrl($CtrlId, $ResName, $ResType = 10, $DLL = -1) ; $RT_RCDATA = 10
	Local $ResData, $nSize, $hData, $pData, $pStream, $pBitmap, $hBitmap

	$ResData = _ResourceGet($ResName, $ResType, 0, $DLL)
	If @error Then Return SetError(1, 0, 0)
	$nSize = @extended

	If $ResType = $RT_BITMAP Then
		_SetBitmapToCtrl($CtrlId, $ResData)
		If @error Then Return SetError(2, 0, 0)
	Else
		; thanks ProgAndy
		; for other types than BITMAP use GDI+ for converting to bitmap first
		$hData = _MemGlobalAlloc($nSize,2)
		$pData = _MemGlobalLock($hData)
		_MemMoveMemory($ResData,$pData,$nSize)
		_MemGlobalUnlock($hData)
		$pStream = DllCall( "ole32.dll","int","CreateStreamOnHGlobal", "ptr",$hData, "int",1, "ptr*",0)
		$pStream = $pStream[3]
		$pBitmap = DllCall($__g_hGDIPDll,"int","GdipCreateBitmapFromStream", "ptr",$pStream, "ptr*",0)
		$pBitmap = $pBitmap[2]
		$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($pBitmap)
		_SetBitmapToCtrl($CtrlId, $hBitmap)
		If @error Then SetError(3, 0, 0)
		_GDIPlus_BitmapDispose($pBitmap)
		_WinAPI_DeleteObject($pStream)
		_MemGlobalFree($hData)
	EndIf

	Return 1
EndFunc


Func _ResourceGet($ResName, $ResType = 10, $ResLang = 0, $DLL = -1) ; $RT_RCDATA = 10
	Local Const $IMAGE_BITMAP = 0
	Local $hInstance, $hBitmap, $InfoBlock, $GlobalMemoryBlock, $MemoryPointer, $ResSize

	If $DLL = -1 Then
	  $hInstance = _WinAPI_GetModuleHandle("")
	Else
	  $hInstance = _WinAPI_LoadLibraryEx($DLL, $LOAD_LIBRARY_AS_DATAFILE)
	EndIf
	If $hInstance = 0 Then Return SetError(1, 0, 0)

	If $ResType = $RT_BITMAP Then
		$hBitmap = _WinAPI_LoadImage($hInstance, $ResName, $IMAGE_BITMAP, 0, 0, 0)
		If @error Then Return SetError(2, 0, 0)
		Return $hBitmap ; returns handle to Bitmap
	EndIf

	If $ResLang <> 0 Then
		$InfoBlock = DllCall("kernel32.dll", "ptr", "FindResourceExW", "ptr", $hInstance, "long", $ResType, "wstr", $ResName, "short", $ResLang)
	Else
		$InfoBlock = DllCall("kernel32.dll", "ptr", "FindResourceW", "ptr", $hInstance, "wstr", $ResName, "long", $ResType)
	EndIf

	If @error Then Return SetError(3, 0, 0)
	$InfoBlock = $InfoBlock[0]
	If $InfoBlock = 0 Then Return SetError(4, 0, 0)

	$ResSize = DllCall("kernel32.dll", "dword", "SizeofResource", "ptr", $hInstance, "ptr", $InfoBlock)
	If @error Then Return SetError(5, 0, 0)
	$ResSize = $ResSize[0]
	If $ResSize = 0 Then Return SetError(6, 0, 0)

	$GlobalMemoryBlock = DllCall("kernel32.dll", "ptr", "LoadResource", "ptr", $hInstance, "ptr", $InfoBlock)
	If @error Then Return SetError(7, 0, 0)
	$GlobalMemoryBlock = $GlobalMemoryBlock[0]
	If $GlobalMemoryBlock = 0 Then Return SetError(8, 0, 0)

	$MemoryPointer = DllCall("kernel32.dll", "ptr", "LockResource", "ptr", $GlobalMemoryBlock)
	If @error Then Return SetError(9, 0, 0)
	$MemoryPointer = $MemoryPointer[0]
	If $MemoryPointer = 0 Then Return SetError(10, 0, 0)

	If $DLL <> -1 Then _WinAPI_FreeLibrary($hInstance)
	If @error Then Return SetError(11, 0, 0)

	SetExtended($ResSize)
	Return $MemoryPointer
EndFunc


; internal helper function
; thanks for improvements Melba
Func _SetBitmapToCtrl($CtrlId, $hBitmap)
    Local Const $STM_SETIMAGE = 0x0172
    Local Const $STM_GETIMAGE = 0x0173
    Local Const $BM_SETIMAGE = 0xF7
    Local Const $BM_GETIMAGE = 0xF6
    Local Const $IMAGE_BITMAP = 0
    Local Const $SS_BITMAP = 0x0E
    Local Const $BS_BITMAP = 0x0080
    Local Const $GWL_STYLE = -16

    Local $hWnd, $hPrev, $Style, $iCtrl_SETIMAGE, $iCtrl_GETIMAGE, $iCtrl_BITMAP

    $hWnd = GUICtrlGetHandle($CtrlId)
    If $hWnd = 0 Then Return SetError(1, 0, 0)

    $CtrlId = _WinAPI_GetDlgCtrlID($hWnd) ; support for $CtrlId = -1
    If @error Then Return SetError(2, 0, 0)

    ; determine control class and adjust constants accordingly
    Switch _WinAPI_GetClassName($CtrlId)
        Case "Button" ; button,checkbox,radiobutton,groupbox
            $iCtrl_SETIMAGE = $BM_SETIMAGE
            $iCtrl_GETIMAGE = $BM_GETIMAGE
            $iCtrl_BITMAP = $BS_BITMAP
        Case "Static" ; picture,icon,label
            $iCtrl_SETIMAGE = $STM_SETIMAGE
            $iCtrl_GETIMAGE = $STM_GETIMAGE
            $iCtrl_BITMAP = $SS_BITMAP
        Case Else
            Return SetError(3, 0, 0)
	EndSwitch

	; set SS_BITMAP/BS_BITMAP style to the control
    $Style = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
    If @error Then Return SetError(4, 0, 0)
    _WinAPI_SetWindowLong($hWnd, $GWL_STYLE, BitOR($Style, $iCtrl_BITMAP))
    If @error Then Return SetError(5, 0, 0)

	; set image to the control
    $hPrev  = _SendMessage($hWnd, $iCtrl_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
    If @error Then Return SetError(6, 0, 0)
    If $hPrev Then _WinAPI_DeleteObject($hPrev)

	Return 1
EndFunc


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; ===============================================================================================================================
Func _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap, $iARGB = 0xFF000000)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateHBITMAPFromBitmap", "handle", $hBitmap, "handle*", 0, "dword", $iARGB)
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] Then Return SetError(10, $aResult[0], 0)

	Return $aResult[2]
EndFunc   ;==>_GDIPlus_BitmapCreateHBITMAPFromBitmap


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; ===============================================================================================================================
Func _GDIPlus_BitmapDispose($hBitmap)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDisposeImage", "handle", $hBitmap)
	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] Then Return SetError(10, $aResult[0], False)

	Return True
EndFunc   ;==>_GDIPlus_BitmapDispose


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_SetWindowLong($hWnd, $iIndex, $iValue)
	_WinAPI_SetLastError(0) ; as suggested in MSDN
	Local $sFuncName = "SetWindowLongW"
	If @AutoItX64 Then $sFuncName = "SetWindowLongPtrW"
	Local $aResult = DllCall("user32.dll", "long_ptr", $sFuncName, "hwnd", $hWnd, "int", $iIndex, "long_ptr", $iValue)
	If @error Then Return SetError(@error, @extended, 0)

	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetWindowLong


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _WinAPI_SetLastError($iErrorCode, $iError = @error, $iExtended = @extended)
	DllCall("kernel32.dll", "none", "SetLastError", "dword", $iErrorCode)
	Return SetError($iError, $iExtended, Null)
EndFunc   ;==>_WinAPI_SetLastError


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: JPM
; ===============================================================================================================================
Func _WinAPI_GetWindowLong($hWnd, $iIndex)
	Local $sFuncName = "GetWindowLongW"
	If @AutoItX64 Then $sFuncName = "GetWindowLongPtrW"
	Local $aResult = DllCall("user32.dll", "long_ptr", $sFuncName, "hwnd", $hWnd, "int", $iIndex)
	If @error Or Not $aResult[0] Then Return SetError(@error + 10, @extended, 0)

	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindowLong


; #FUNCTION# ====================================================================================================================
; Author ........: Valik
; Modified.......: Gary Frost (GaryFrost) aka gafrost
; ===============================================================================================================================
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
	Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
	If @error Then Return SetError(@error, @extended, "")
	If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
	Return $aResult
EndFunc   ;==>_SendMessage


; #FUNCTION# ====================================================================================================================
; Author ........: Wouter van Kesteren.
; ===============================================================================================================================
Func _INetGetSource($sURL, $bString = True)
	Local $sString = InetRead($sURL, $INET_FORCERELOAD)
	Local $iError = @error, $iExtended = @extended
	If $bString = Default Or $bString Then $sString = BinaryToString($sString)
	Return SetError($iError, $iExtended, $sString)
EndFunc   ;==>_INetGetSource


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _MemGlobalAlloc($iBytes, $iFlags = 0)
	Local $aResult = DllCall("kernel32.dll", "handle", "GlobalAlloc", "uint", $iFlags, "ulong_ptr", $iBytes)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_MemGlobalAlloc


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _MemGlobalLock($hMem)
	Local $aResult = DllCall("kernel32.dll", "ptr", "GlobalLock", "handle", $hMem)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_MemGlobalLock


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _MemMoveMemory($pSource, $pDest, $iLength)
	DllCall("kernel32.dll", "none", "RtlMoveMemory", "struct*", $pDest, "struct*", $pSource, "ulong_ptr", $iLength)
	If @error Then Return SetError(@error, @extended)
EndFunc   ;==>_MemMoveMemory


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _MemGlobalUnlock($hMem)
	Local $aResult = DllCall("kernel32.dll", "bool", "GlobalUnlock", "handle", $hMem)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_MemGlobalUnlock


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _WinAPI_DeleteObject($hObject)
	Local $aResult = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hObject)
	If @error Then Return SetError(@error, @extended, False)

	Return $aResult[0]
EndFunc   ;==>_WinAPI_DeleteObject


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _MemGlobalFree($hMem)
	Local $aResult = DllCall("kernel32.dll", "ptr", "GlobalFree", "handle", $hMem)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_MemGlobalFree


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_GetModuleHandle($sModuleName)
	Local $sModuleNameType = "wstr"
	If $sModuleName = "" Then
		$sModuleName = 0
		$sModuleNameType = "ptr"
	EndIf

	Local $aResult = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $sModuleNameType, $sModuleName)
	If @error Then Return SetError(@error, @extended, 0)

	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetModuleHandle


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _WinAPI_LoadLibraryEx($sFileName, $iFlags = 0)
	Local $aResult = DllCall("kernel32.dll", "handle", "LoadLibraryExW", "wstr", $sFileName, "ptr", 0, "dword", $iFlags)
	If @error Then Return SetError(@error, @extended, 0)

	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadLibraryEx


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _WinAPI_LoadImage($hInstance, $sImage, $iType, $iXDesired, $iYDesired, $iLoad)
	Local $aResult, $sImageType = "int"
	If IsString($sImage) Then $sImageType = "wstr"
	$aResult = DllCall("user32.dll", "handle", "LoadImageW", "handle", $hInstance, $sImageType, $sImage, "uint", $iType, _
			"int", $iXDesired, "int", $iYDesired, "uint", $iLoad)
	If @error Then Return SetError(@error, @extended, 0)

	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadImage


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_FreeLibrary($hModule)
	Local $aResult = DllCall("kernel32.dll", "bool", "FreeLibrary", "handle", $hModule)
	If @error Then Return SetError(@error, @extended, False)

	Return $aResult[0]
EndFunc   ;==>_WinAPI_FreeLibrary


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_GetDlgCtrlID($hWnd)
	Local $aResult = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDlgCtrlID


; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: JPM
; ===============================================================================================================================
Func _WinAPI_GetClassName($hWnd)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $aResult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
	If @error Or Not $aResult[0] Then Return SetError(@error, @extended, '')

	Return SetExtended($aResult[0], $aResult[2])
EndFunc   ;==>_WinAPI_GetClassName