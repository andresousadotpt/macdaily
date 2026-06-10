import Foundation

public struct PreviewElementColors: Codable, Sendable, Equatable, Hashable {
    public var body: CodableColor
    public var heading1: CodableColor
    public var heading2: CodableColor
    public var heading3: CodableColor
    public var heading4: CodableColor
    public var heading5: CodableColor
    public var heading6: CodableColor
    public var bold: CodableColor
    public var italic: CodableColor
    public var underline: CodableColor
    public var strikethrough: CodableColor
    public var inlineCode: CodableColor
    public var inlineCodeBackground: CodableColor
    public var codeBlock: CodableColor
    public var codeBlockBackground: CodableColor
    public var link: CodableColor
    public var blockquote: CodableColor
    public var blockquoteBar: CodableColor
    public var listMarker: CodableColor
    public var listText: CodableColor
    public var thematicBreak: CodableColor
    public var tableHeader: CodableColor
    public var tableBorder: CodableColor

    public init(
        body: CodableColor = .rgb(6, 6, 6),
        heading1: CodableColor = .rgb(6, 6, 6),
        heading2: CodableColor = .rgb(6, 6, 6),
        heading3: CodableColor = .rgb(6, 6, 6),
        heading4: CodableColor = .rgb(6, 6, 6),
        heading5: CodableColor = .rgb(6, 6, 6),
        heading6: CodableColor = .rgb(107, 110, 123),
        bold: CodableColor = .rgb(6, 6, 6),
        italic: CodableColor = .rgb(6, 6, 6),
        underline: CodableColor = .rgb(44, 101, 207),
        strikethrough: CodableColor = .rgb(107, 110, 123),
        inlineCode: CodableColor = .rgb(6, 6, 6),
        inlineCodeBackground: CodableColor = .rgb(247, 247, 249),
        codeBlock: CodableColor = .rgb(6, 6, 6),
        codeBlockBackground: CodableColor = .rgb(247, 247, 249),
        link: CodableColor = .rgb(44, 101, 207),
        blockquote: CodableColor = .rgb(107, 110, 123),
        blockquoteBar: CodableColor = .rgb(228, 228, 232),
        listMarker: CodableColor = .rgb(6, 6, 6),
        listText: CodableColor = .rgb(6, 6, 6),
        thematicBreak: CodableColor = .rgb(228, 228, 232),
        tableHeader: CodableColor = .rgb(6, 6, 6),
        tableBorder: CodableColor = .rgb(228, 228, 232)
    ) {
        self.body = body
        self.heading1 = heading1
        self.heading2 = heading2
        self.heading3 = heading3
        self.heading4 = heading4
        self.heading5 = heading5
        self.heading6 = heading6
        self.bold = bold
        self.italic = italic
        self.underline = underline
        self.strikethrough = strikethrough
        self.inlineCode = inlineCode
        self.inlineCodeBackground = inlineCodeBackground
        self.codeBlock = codeBlock
        self.codeBlockBackground = codeBlockBackground
        self.link = link
        self.blockquote = blockquote
        self.blockquoteBar = blockquoteBar
        self.listMarker = listMarker
        self.listText = listText
        self.thematicBreak = thematicBreak
        self.tableHeader = tableHeader
        self.tableBorder = tableBorder
    }
}
