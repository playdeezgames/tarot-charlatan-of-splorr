Imports Spectre.Console

Friend Module Utility
    Friend Sub OkPrompt()
        Dim prompt As New SelectionPrompt(Of String) With {.Title = String.Empty}
        prompt.AddChoice(OK_TEXT)
        AnsiConsole.Prompt(prompt)
    End Sub
    Friend Function Confirm(caption As String) As Boolean
        Dim prompt As New SelectionPrompt(Of String) With {.Title = caption}
        prompt.AddChoice(NO_TEXT)
        prompt.AddChoice(YES_TEXT)
        Return AnsiConsole.Prompt(prompt) = YES_TEXT
    End Function
End Module
