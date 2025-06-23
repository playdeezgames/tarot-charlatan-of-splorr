Friend Class ReadingPositionDescriptor
    Implements IReadingPosition
    Sub New(position As ReadingPosition, name As String)
        Me.Position = position
        Me.Name = name
    End Sub
    Public ReadOnly Property Position As ReadingPosition Implements IReadingPosition.Position
    Public ReadOnly Property Name As String Implements IReadingPosition.Name
End Class
