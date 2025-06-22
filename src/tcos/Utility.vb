Imports Spectre.Console

Friend Module Utility
    Friend Sub OkPrompt()
        Dim prompt As New SelectionPrompt(Of String) With {.Title = String.Empty}
        prompt.AddChoice(OK_TEXT)
        AnsiConsole.Prompt(prompt)
    End Sub
End Module
