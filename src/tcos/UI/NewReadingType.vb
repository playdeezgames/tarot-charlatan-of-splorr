Imports Spectre.Console

Friend Module NewReadingType
    Friend Sub Run(question As String)
        AnsiConsole.Clear()
        AnsiConsole.MarkupLine($"[olive]Question:[/]{question}")
        Dim prompt As New SelectionPrompt(Of String) With {.Title = "[olive]Reading Type:[/]"}
        prompt.AddChoice(NEVER_MIND_TEXT)
        Dim table = ReadingTypes.Descriptors.ToDictionary(Function(x) x.Value.Name, Function(x) x.Key)
        prompt.AddChoices(table.Keys)
        Dim answer = AnsiConsole.Prompt(prompt)
        If answer = NEVER_MIND_TEXT Then
            Return
        End If
        Dim readingType = table(answer)
        NewReading.Run(question, readingType)
    End Sub
End Module
