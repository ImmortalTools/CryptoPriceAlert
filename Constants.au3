#cs ----------------------------------------------------------------------------

	Constants for:...CryptoPriceAlert
	Author:..........ImmortalTools

	Version:...1
	Changes:...first release

#ce ----------------------------------------------------------------------------

; GUI control Windows style constants:
;Window styles
Global Const $WS_BORDER = 0x00800000
Global Const $WS_POPUP = 0x80000000
Global Const $WS_SYSMENU = 0x00080000
;Window extended styles
Global Const $WS_EX_TOOLWINDOW = 0x00000080
Global Const $WS_EX_TOPMOST = 0x00000008
Global Const $WS_EX_TRANSPARENT = 0x00000020
;Messages
Global Const $WM_SYSCOMMAND = 0x0112
Global Const $WM_SYSMENU = 0x0313

; GUI constants:
;GUI events
Global Const $GUI_SHOW = 16
;GUI messages
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_EVENT_PRIMARYDOWN = -7
Global Const $GUI_EVENT_PRIMARYUP = -8
;GUI control Label/Static style
Global Const $SS_CENTERIMAGE = 0x0200
Global Const $SS_NOTIFY = 0x0100

; Tray constants:
;Tray menu/item state values
Global Const $TRAY_CHECKED = 1
Global Const $TRAY_UNCHECKED = 4
;TraySetState values
Global Const $TRAY_ICONSTATE_SHOW = 1

; Colour Constants RGB Hex:
Global Const $COLOR_BLUE = 0x0000FF
Global Const $COLOR_GREEN = 0x008000
Global Const $COLOR_RED = 0xFF0000

; Resource constants:
Global Const $RT_BITMAP = 2

; Microsoft Windows GDI+ constants:
Global $__g_hGDIPDll = 0

; WinAPI Constants
;GetWindowLong Constants
Global Const $GWL_EXSTYLE = 0xFFFFFFEC
;LoadLibraryEx Constants
Global Const $LOAD_LIBRARY_AS_DATAFILE = 0x02

; UBound Constants
Global Const $UBOUND_ROWS = 1

; Inet constants
Global Const $INET_FORCERELOAD = 1