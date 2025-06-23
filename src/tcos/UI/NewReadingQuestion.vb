Imports Spectre.Console

Friend Module NewReadingQuestion
    Friend Sub Run()
        AnsiConsole.Clear()
        Dim question = AnsiConsole.Ask("[olive]What is the question or concern for the oracle?[/]", String.Empty)
        If Not String.IsNullOrWhiteSpace(question) Then
            NewReadingType.Run(question)
        End If
    End Sub
End Module
