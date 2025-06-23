Public Class Card
    Sub New(cardType As CardType, reversed As Boolean)
        Me.CardType = cardType
        Me.Reversed = reversed
    End Sub

    Public ReadOnly Property CardType As CardType
    Public Property Reversed As Boolean
    Public Overrides Function ToString() As String
        Return $"{CardType.ToDescriptor.Name}{If(Reversed, "(reversed)", "")}"
    End Function
End Class
