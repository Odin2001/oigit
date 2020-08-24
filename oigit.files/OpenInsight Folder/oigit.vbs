Option Explicit
Dim Revelation
Set Revelation = CreateObject("RevSoft.Revelation")

' Declare variables
Dim Engine
Dim Result
Dim Queue
Dim strCmd
Dim RetVal
Dim myName
Dim strArgs
Dim allArgs
Set strArgs = WScript.Arguments
Dim i
Dim Database
Dim Username
Dim Password
Database = "SYSPROG"
Username = "SYSPROG"
Password = ""

For i = 0 to strArgs.Count - 1
	allArgs = allArgs & " " & strArgs.Item(i)
Next

Result = Revelation.CreateEngine(Engine, "\\.\OIGIT", Database, 1, 1)
'Result = Revelation.CreateEngine(Engine, "\\.\OIGIT", "SYSPROG", 1, 1)

If Result = 0 Then
	'Create an active Queue.
	'The fi
	Result = Engine.CreateQueue(Queue, "oigit", Database, Username, Password)
	'Result = Engine.CreateQueue(Queue, "oigit", "SYSPROG", "SYSPROG","")
	If Result = 0 Then
		'Call a Basic+ function...
		Dim ReturnValue
		Result = Queue.CallFunction(ReturnValue, "OIGIT", allArgs)
		Queue.CloseQueue
	End If
	Engine.CloseEngine
End If
Set Queue = Nothing
Set Engine = Nothing
Set Revelation = Nothing