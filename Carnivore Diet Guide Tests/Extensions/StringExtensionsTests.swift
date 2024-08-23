//
//  StringExtensionsTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 8/22/24.
//

import XCTest

final class StringExtensionsTests: XCTestCase {
    
    func testStripHeaders() {
        let input = "# Header\n## Subheader\n### Sub-subheader"
        let expected = "Header\nSubheader\nSub-subheader"
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripBold() {
        let input = "This is **bold** and __also bold__."
        let expected = "This is bold and also bold."
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripItalics() {
        let input = "This is *italic* and _also italic_."
        let expected = "This is italic and also italic."
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripLinks() {
        let input = "Here is a [link](https://example.com)."
        let expected = "Here is a link."
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripImages() {
        let input = "Here is an ![image](https://example.com/image.png)."
        let expected = "Here is an image."
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripInlineCode() {
        let input = "Here is some `inline code`."
        let expected = "Here is some inline code."
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripStrikethrough() {
        let input = "This is ~~strikethrough~~ text."
        let expected = "This is strikethrough text."
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripBlockquotes() {
        let input = "> This is a blockquote."
        let expected = "This is a blockquote."
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripUnorderedList() {
        let input = "- Item 1\n* Item 2\n+ Item 3"
        let expected = "Item 1\nItem 2\nItem 3"
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripOrderedList() {
        let input = "1. Item 1\n2. Item 2\n3. Item 3"
        let expected = "Item 1\nItem 2\nItem 3"
        XCTAssertEqual(input.stripMarkdown(), expected)
    }

    func testStripMultipleElements() {
        let input = """
        # Header
        This is **bold** text and this is *italic* text.
        Here is a [link](https://example.com) and an ![image](https://example.com/image.png).
        > Blockquote
        1. Ordered item
        - Unordered item
        `Code`
        """
        let expected = """
        Header
        This is bold text and this is italic text.
        Here is a link and an image.
        Blockquote
        Ordered item
        Unordered item
        Code
        """
        XCTAssertEqual(input.stripMarkdown(), expected)
    }
}
