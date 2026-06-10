import AppKit
import SwiftUI
import MacDailyCore

final class FormattingTextView: NSTextView {
    var keyboardShortcuts: KeyboardShortcuts = KeyboardShortcuts()
    var onFormat: ((MarkdownFormatAction) -> Void)?

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if let action = keyboardShortcuts.matchingAction(for: event) {
            Task { @MainActor in
                onFormat?(action)
            }
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    override func paste(_ sender: Any?) {
        guard let plain = NSPasteboard.general.string(forType: .string) else {
            super.paste(sender)
            return
        }
        insertText(plain, replacementRange: selectedRange())
    }
}

struct MarkdownTextEditor: NSViewRepresentable {
    @Binding var text: String
    var appearance: AppearanceSettings
    var font: NSFont
    var lineSpacing: CGFloat
    var backgroundColor: NSColor
    var keyboardShortcuts: KeyboardShortcuts
    @Binding var formatRequest: MarkdownFormatAction?
    var onTextChange: (String) -> Void

    private var usesPreviewColors: Bool {
        AppearanceFormatting.editorUsesPreviewColors(appearance)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> MarkdownEditorContainerView {
        let container = MarkdownEditorContainerView()
        let scrollView = container.scrollView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = backgroundColor

        let textView = FormattingTextView()
        textView.delegate = context.coordinator
        textView.isRichText = usesPreviewColors
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainerInset = NSSize(width: 0, height: 0)
        textView.drawsBackground = true
        textView.backgroundColor = backgroundColor
        textView.textColor = .labelColor
        textView.insertionPointColor = .labelColor
        textView.font = font
        textView.keyboardShortcuts = keyboardShortcuts
        textView.onFormat = { action in
            context.coordinator.applyFormat(action)
        }

        scrollView.documentView = textView
        context.coordinator.containerView = container
        context.coordinator.configure(textView: textView, text: text)
        context.coordinator.textView = textView
        context.coordinator.configureLineNumbers(textView: textView)
        return container
    }

    func updateNSView(_ container: MarkdownEditorContainerView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.containerView = container
        guard let textView = context.coordinator.textView else { return }

        let scrollView = container.scrollView
        textView.isRichText = usesPreviewColors
        textView.backgroundColor = backgroundColor
        textView.textColor = .labelColor
        textView.insertionPointColor = .labelColor
        scrollView.backgroundColor = backgroundColor
        textView.font = font
        textView.keyboardShortcuts = keyboardShortcuts
        context.coordinator.configureLineNumbers(textView: textView)

        if textView.string != text {
            let selectedRange = textView.selectedRange()
            context.coordinator.setContent(text, on: textView, preserving: selectedRange)
        } else {
            context.coordinator.refreshHighlighting(on: textView)
        }

        if let action = formatRequest {
            context.coordinator.applyFormat(action)
            DispatchQueue.main.async {
                formatRequest = nil
            }
        }
    }

    static func dismantleNSView(_ nsView: MarkdownEditorContainerView, coordinator: Coordinator) {
        coordinator.teardown()
    }

    fileprivate static func lineNumberFont(for editorFont: NSFont) -> NSFont {
        NSFont.monospacedDigitSystemFont(ofSize: max(10, editorFont.pointSize * 0.85), weight: .regular)
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextEditor
        weak var containerView: MarkdownEditorContainerView?
        weak var textView: FormattingTextView?
        private var isUpdatingHighlight = false

        init(parent: MarkdownTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView, !isUpdatingHighlight else { return }
            parent.text = textView.string
            refreshHighlighting(on: textView)
            parent.onTextChange(textView.string)
            refreshLineNumbers()
        }

        func configureLineNumbers(textView: FormattingTextView) {
            guard let containerView else { return }

            removeScrollObserver()

            guard parent.appearance.showLineNumbers else {
                containerView.gutterView.textView = nil
                containerView.setLineNumbersVisible(false)
                return
            }

            let gutterFont = MarkdownTextEditor.lineNumberFont(for: parent.font)
            containerView.gutterView.textView = textView
            containerView.gutterView.update(
                font: gutterFont,
                textColor: .secondaryLabelColor,
                backgroundColor: parent.backgroundColor
            )
            containerView.setLineNumbersVisible(true)
            containerView.gutterView.refresh()

            let contentView = containerView.scrollView.contentView
            contentView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleScrollBoundsChange),
                name: NSView.boundsDidChangeNotification,
                object: contentView
            )
        }

        @objc private func handleScrollBoundsChange(_ notification: Notification) {
            containerView?.gutterView.needsDisplay = true
        }

        private func removeScrollObserver() {
            if let textView, let contentView = textView.enclosingScrollView?.contentView {
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSView.boundsDidChangeNotification,
                    object: contentView
                )
            }
        }

        func teardown() {
            removeScrollObserver()
        }

        private func refreshLineNumbers() {
            guard parent.appearance.showLineNumbers, let containerView else { return }
            let previousWidth = containerView.gutterView.requiredWidth
            containerView.gutterView.refresh()
            if containerView.gutterView.requiredWidth != previousWidth {
                containerView.gutterWidthChanged()
            }
        }

        func configure(textView: FormattingTextView, text: String) {
            setContent(text, on: textView, preserving: NSRange(location: 0, length: 0))
        }

        @MainActor func setContent(_ text: String, on textView: FormattingTextView, preserving selectedRange: NSRange) {
            isUpdatingHighlight = true
            defer { isUpdatingHighlight = false }

            if parent.usesPreviewColors {
                let highlighted = MarkdownEditorHighlighter.highlight(text, appearance: parent.appearance)
                textView.textStorage?.setAttributedString(highlighted)
            } else {
                textView.string = text
                applyPlainStyle(to: textView)
            }

            textView.setSelectedRange(selectedRange.clamped(to: (textView.string as NSString).length))
            refreshLineNumbers()
        }

        func refreshHighlighting(on textView: FormattingTextView) {
            guard parent.usesPreviewColors else {
                applyPlainStyle(to: textView)
                return
            }

            let selectedRange = textView.selectedRange()
            isUpdatingHighlight = true
            defer { isUpdatingHighlight = false }

            let highlighted = MarkdownEditorHighlighter.highlight(textView.string, appearance: parent.appearance)
            textView.textStorage?.setAttributedString(highlighted)
            textView.setSelectedRange(selectedRange.clamped(to: (textView.string as NSString).length))
            refreshLineNumbers()
        }

        private func applyPlainStyle(to textView: FormattingTextView) {
            guard let textStorage = textView.textStorage else { return }
            let range = NSRange(location: 0, length: textStorage.length)
            textStorage.addAttribute(.font, value: parent.font, range: range)
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: range)
            textStorage.removeAttribute(.backgroundColor, range: range)
            textStorage.removeAttribute(.underlineStyle, range: range)
            textStorage.removeAttribute(.strikethroughStyle, range: range)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = parent.lineSpacing
            textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        }

        @MainActor func applyFormat(_ action: MarkdownFormatAction) {
            guard let textView else { return }
            let result = MarkdownFormatting.apply(action, to: textView.string, range: textView.selectedRange())
            setContent(result.text, on: textView, preserving: result.selectedRange)
            parent.text = result.text
            parent.onTextChange(result.text)
        }
    }
}

private extension NSRange {
    func clamped(to length: Int) -> NSRange {
        let safeLocation = min(max(location, 0), length)
        let maxLength = max(length - safeLocation, 0)
        let safeLength = min(max(self.length, 0), maxLength)
        return NSRange(location: safeLocation, length: safeLength)
    }
}
