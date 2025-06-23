Friend Class Deck
    Friend ReadOnly Property Cards As New List(Of Card)
    Sub New()
        Reset()
    End Sub
    Private Sub Reset()
        Cards.Clear()
        For Each cardType As CardType In [Enum].GetValues(Of CardType)
            Cards.Add(New Card(cardType, False))
        Next
    End Sub

    Friend Sub Shuffle(random As Random)
        Reset()
        Dim originalCards As New List(Of Card)(Cards)
        Cards.Clear()
        While originalCards.Any
            Dim card = originalCards(random.Next(originalCards.Count))
            card.Reversed = random.Next(2) > 0
            originalCards.Remove(card)
            Cards.Add(card)
        End While
    End Sub

    Friend Function Draw() As Card
        Dim card = Cards.First
        Cards.Remove(card)
        Return card
    End Function
End Class
