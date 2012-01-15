' Restores glue binaries from a USB drive,
' Restores the autorun file,
' And reassigns the volume label.

set fso = CreateObject("Scripting.FileSystemObject")
set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
set shell = WScript.CreateObject("WScript.Shell")

usb = InputBox("Where is the USB drive?", "Glue Installer", "E:")

autorun = usb & "\autorun.inf"
glue = usb & "\glue"

fso.DeleteFile autorun, True
fso.DeleteFolder glue, True

set colDrives = objWMIService.ExecQuery("Select * from Win32_LogicalDisk where DeviceID = '" & usb & "'")
for Each objDrive in colDrives
	objDrive.VolumeName = "HD"
	objDrive.Put_
next

cwd = Replace(WScript.ScriptFullName, WScript.ScriptName, "")
cwd = mid(cwd, 1, len(cwd) - 1) ' Remove trailing backslash

autorun = cwd & "\autorun.inf"

fso.CopyFile autorun, usb & "\", True
fso.CopyFolder cwd, usb & "\", True

set colDrives = objWMIService.ExecQuery("Select * from Win32_LogicalDisk where DeviceID = '" & usb & "'")
for Each objDrive in colDrives
	objDrive.VolumeName = "Glue"
	objDrive.Put_
next

MsgBox "Success", 0, "Glue Installer"