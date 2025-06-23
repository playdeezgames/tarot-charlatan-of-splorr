Public Interface IReadingType
    ReadOnly Property ReadingType As ReadingType
    ReadOnly Property Name As String
    ReadOnly Property Positions As IReadOnlyList(Of ReadingPosition)
End Interface
