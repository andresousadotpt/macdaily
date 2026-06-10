import AppKit

final class LineNumberGutterView: NSView {
    weak var textView: NSTextView?

    var numberFont: NSFont
    var numberColor: NSColor
    var gutterBackgroundColor: NSColor

    private(set) var requiredWidth: CGFloat = 36

    init(
        font: NSFont,
        textColor: NSColor = .secondaryLabelColor,
        backgroundColor: NSColor = .textBackgroundColor
    ) {
        self.numberFont = font
        self.numberColor = textColor
        self.gutterBackgroundColor = backgroundColor
        super.init(frame: .zero)
        wantsLayer = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(font: NSFont, textColor: NSColor, backgroundColor: NSColor) {
        numberFont = font
        numberColor = textColor
        gutterBackgroundColor = backgroundColor
        updateRequiredWidth()
        needsDisplay = true
    }

    func updateRequiredWidth() {
        guard let textView else {
            requiredWidth = 36
            return
        }
        let lineCount = max(1, textView.string.components(separatedBy: "\n").count)
        let digits = max(2, String(lineCount).count)
        requiredWidth = CGFloat(digits * 9 + 14)
    }

    func refresh() {
        updateRequiredWidth()
        needsDisplay = true
    }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        gutterBackgroundColor.setFill()
        dirtyRect.fill()

        guard let textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: numberFont,
            .foregroundColor: numberColor,
        ]

        let visibleRect = textView.visibleRect
        let origin = textView.textContainerOrigin
        let relativePoint = convert(NSZeroPoint, from: textView)
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        let string = textView.string as NSString
        if string.length == 0 {
            let lineHeight = numberFont.boundingRectForFont.height
            let drawY = relativePoint.y + origin.y
            drawLineNumber(1, y: drawY, lineHeight: lineHeight, attributes: attributes)
            return
        }

        var lineNumber = 1
        var index = 0

        while index <= string.length {
            let lineRange = string.lineRange(for: NSRange(location: min(index, string.length), length: 0))
            let intersectsVisible = NSMaxRange(lineRange) > characterRange.location
                && lineRange.location <= NSMaxRange(characterRange)

            if intersectsVisible {
                let glyphLineRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
                if glyphLineRange.location != NSNotFound {
                    let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphLineRange.location, effectiveRange: nil)
                    let drawY = relativePoint.y + lineRect.origin.y + origin.y

                    if drawY + lineRect.height >= 0, drawY <= bounds.height {
                        drawLineNumber(
                            lineNumber,
                            y: drawY,
                            lineHeight: lineRect.height,
                            attributes: attributes
                        )
                    }
                }
            }

            lineNumber += 1
            let nextIndex = NSMaxRange(lineRange)
            if nextIndex <= index { break }
            index = nextIndex
        }
    }

    private func drawLineNumber(
        _ number: Int,
        y: CGFloat,
        lineHeight: CGFloat,
        attributes: [NSAttributedString.Key: Any]
    ) {
        let label = "\(number)" as NSString
        let size = label.size(withAttributes: attributes)
        let x = requiredWidth - size.width - 8
        let baselineY = y + (lineHeight - size.height) / 2
        label.draw(at: NSPoint(x: x, y: baselineY), withAttributes: attributes)
    }
}

final class MarkdownEditorContainerView: NSView {
    let scrollView = NSScrollView()
    let gutterView = LineNumberGutterView(
        font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    )

    private var showsLineNumbers = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        gutterView.isHidden = true
        addSubview(gutterView)
        addSubview(scrollView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLineNumbersVisible(_ visible: Bool) {
        showsLineNumbers = visible
        gutterView.isHidden = !visible
        layoutGutterAndScrollView()
    }

    func gutterWidthChanged() {
        layoutGutterAndScrollView()
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        layoutGutterAndScrollView()
    }

    private func layoutGutterAndScrollView() {
        let gutterWidth = showsLineNumbers ? gutterView.requiredWidth : 0
        gutterView.frame = NSRect(x: 0, y: 0, width: gutterWidth, height: bounds.height)
        scrollView.frame = NSRect(
            x: gutterWidth,
            y: 0,
            width: max(0, bounds.width - gutterWidth),
            height: bounds.height
        )
    }
}
