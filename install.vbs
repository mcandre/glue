' Copies glue binaries to a USB drive,
' Adds an autorun file,
' And assigns a volume label.

set fso = CreateObject("Scripting.FileSystemObject")
set shell = WScript.CreateObject("WScript.Shell")
set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")

cwd = Replace(WScript.ScriptFullName, WScript.ScriptName, "")
cwd = mid(cwd, 1, len(cwd) - 1) ' Remove trailing backslash

autorun = cwd & "\autorun.inf"

usb = InputBox("Where is the USB drive?", "Glue Installer", "E:")

fso.CopyFile autorun, usb & "\", True
fso.CopyFolder cwd, usb & "\", True

set colDrives = objWMIService.ExecQuery("Select * from Win32_LogicalDisk where DeviceID = '" & usb & "'")
for Each objDrive in colDrives
	objDrive.VolumeName = "Glue"
	objDrive.Put_
next

MsgBox "Success", 0, "Glue Installer"