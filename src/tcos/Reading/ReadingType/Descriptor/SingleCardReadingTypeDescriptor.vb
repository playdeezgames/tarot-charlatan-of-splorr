Friend Class SingleCardReadingTypeDescriptor
    Implements IReadingType

    Public ReadOnly Property ReadingType As ReadingType Implements IReadingType.ReadingType
        Get
            Return ReadingType.SingleCard
        End Get
    End Property

    Public ReadOnly Property Name As String Implements IReadingType.Name
        Get
            Return "Single Card"
        End Get
    End Property

    Public ReadOnly Property Positions As IReadOnlyList(Of ReadingPosition) Implements IReadingType.Positions
        Get
            Return {ReadingPosition.SingleCard}.ToList
        End Get
    End Property
End Class
