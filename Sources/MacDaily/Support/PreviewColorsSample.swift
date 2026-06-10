import Foundation

enum PreviewColorsSample {
    static let markdown = """
    # Heading 1

    ## Heading 2

    ### Heading 3

    #### Heading 4

    ##### Heading 5

    ###### Heading 6

    Body text with **bold**, *italic*, ***bold italic***, ~~strikethrough~~, `inline code`, a [link](https://example.com), and <u>underlined HTML</u>.

    > Blockquote — a quoted passage with secondary styling.

    ---

    - Bulleted list item
    - Second item with **bold**
      - Nested item

    1. Numbered list
    2. Second step

    - [x] Completed task
    - [ ] Open task

    ```swift
    func hello() {
        print("Code block")
    }
    ```

    | Style | Example |
    | ----- | ------- |
    | **Bold** | `**text**` |
    | *Italic* | `*text*` |
    """
}
