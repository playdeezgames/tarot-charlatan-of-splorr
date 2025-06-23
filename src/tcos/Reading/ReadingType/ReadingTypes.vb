Imports System.Runtime.CompilerServices

Friend Module ReadingTypes
    Friend Descriptors As IReadOnlyDictionary(Of ReadingType, IReadingType) =
        New List(Of IReadingType) From
        {
            New SingleCardReadingTypeDescriptor()
        }.ToDictionary(Function(x) x.ReadingType, Function(x) x)
    <Extension>
    Friend Function ToDescriptor(readingType As ReadingType) As IReadingType
        Return Descriptors(readingType)
    End Function
End Module
