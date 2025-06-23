Friend Class CardTypeDescriptor
    Implements ICardType
    Sub New(cardType As CardType, name As String)
        Me.CardType = cardType
        Me.Name = name
    End Sub

    Public ReadOnly Property CardType As CardType Implements ICardType.CardType

    Public ReadOnly Property Name As String Implements ICardType.Name
End Class
