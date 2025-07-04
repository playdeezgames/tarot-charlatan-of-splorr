﻿Imports Spectre.Console

Friend Module MainMenu
    Friend Sub Run()
        Do
            AnsiConsole.Clear()
            Dim prompt As New SelectionPrompt(Of String) With {.Title = MAIN_MENU_CAPTION}
            prompt.AddChoice(NEW_READING_TEXT)
            prompt.AddChoice(QUIT_TEXT)
            Select Case AnsiConsole.Prompt(prompt)
                Case NEW_READING_TEXT
                    NewReadingQuestion.Run()
                Case QUIT_TEXT
                    If Utility.Confirm(QUIT_CONFIRM_CAPTION) Then
                        Exit Do
                    End If
                Case Else
                    Throw New NotImplementedException
            End Select
        Loop
    End Sub
End Module
