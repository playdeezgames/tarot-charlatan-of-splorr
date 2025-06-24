Friend Class ThreeCardReadingTypeDescriptor
    Implements IReadingType

    Public ReadOnly Property ReadingType As ReadingType Implements IReadingType.ReadingType
        Get
            Return ReadingType.ThreeCard
        End Get
    End Property

    Public ReadOnly Property Name As String Implements IReadingType.Name
        Get
            Return "Three Card(Past, Present, Future)"
        End Get
    End Property

    Public ReadOnly Property Positions As IReadOnlyList(Of ReadingPosition) Implements IReadingType.Positions
        Get
            Return {ReadingPosition.Past, ReadingPosition.Present, ReadingPosition.Future}.ToList
        End Get
    End Property
End Class
