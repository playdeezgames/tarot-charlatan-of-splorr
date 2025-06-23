Imports Spectre.Console

Friend Module NewReading
    Friend Sub Run(question As String, readingType As ReadingType)
        AnsiConsole.Clear()
        AnsiConsole.MarkupLine($"[olive]Question:[/]{question}")
        AnsiConsole.MarkupLine($"[olive]Reading Type:[/]{readingType.ToDescriptor.Name}")
        Dim deck As New Deck()
        Dim random As New Random
        deck.Shuffle(random)
        Dim cards As New Dictionary(Of ReadingPosition, Card)
        For Each position In readingType.ToDescriptor.Positions
            Dim card = deck.Draw
            cards(position) = card
            AnsiConsole.MarkupLine($"[olive]{position.ToDescriptor.Name}:[/]{card}")
        Next
        OkPrompt()
    End Sub
End Module
