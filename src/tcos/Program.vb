Module Program
    Sub Main(args As String())
        ArgumentNullException.ThrowIfNull(args)
        Console.Title = APPLICATION_TITLE
        SplashScreen.Run()
    End Sub
End Module
