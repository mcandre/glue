' Deletes glue binaries from a USB drive,
' Deletes the autorun file,
' And reassigns the volume label.

set fso = CreateObject("Scripting.FileSystemObject")
set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")

usb = InputBox("Where is the USB drive?", "Glue Uninstaller", "E:")

autorun = usb & "\autorun.inf"
glue = usb & "\glue"

fso.DeleteFile autorun, True
fso.DeleteFolder glue, True

set colDrives = objWMIService.ExecQuery("Select * from Win32_LogicalDisk where DeviceID = '" & usb & "'")
for Each objDrive in colDrives
	objDrive.VolumeName = "HD"
	objDrive.Put_
next

MsgBox "Success", 0, "Glue Uninstaller"