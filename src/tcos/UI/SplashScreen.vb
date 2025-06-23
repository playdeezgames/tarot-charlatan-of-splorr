Imports Spectre.Console

Friend Module SplashScreen
    Friend Sub Run()
        AnsiConsole.Clear()
        Dim figlet As New FigletText(APPLICATION_TITLE) With {.Color = Color.Fuchsia, .Justification = Justify.Center}
        AnsiConsole.Write(figlet)
        OkPrompt()
        MainMenu.Run()
    End Sub
End Module
