Imports System.Runtime.CompilerServices

Friend Module ReadingPositions
    Friend ReadOnly Descriptors As IReadOnlyDictionary(Of ReadingPosition, IReadingPosition) =
        New List(Of IReadingPosition) From
        {
            New ReadingPositionDescriptor(ReadingPosition.SingleCard, "Single Card")
        }.ToDictionary(Function(x) x.Position, Function(x) x)
    <Extension>
    Friend Function ToDescriptor(position As ReadingPosition) As IReadingPosition
        Return Descriptors(position)
    End Function
End Module
