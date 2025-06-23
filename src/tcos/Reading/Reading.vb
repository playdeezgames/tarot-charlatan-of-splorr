Public Class Reading
    Public ReadOnly Question As String
    Public ReadOnly ReadingType As ReadingType
    Public ReadOnly Cards As IReadOnlyDictionary(Of ReadingPosition, Card)
    Public Sub New(question As String, readingType As ReadingType, cards As IReadOnlyDictionary(Of ReadingPosition, Card))
        Me.Question = question
        Me.ReadingType = readingType
        Me.Cards = cards
    End Sub
End Class
