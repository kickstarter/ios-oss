@testable import ServerDrivenUI
import Testing

@Suite("RichTextElement.HeaderLevel parsing")
struct RichTextElementHeaderLevelTests {
  @Test("Parses single valid heading style: HEADING_1")
  func parsesSingleValidHeading1() async throws {
    let level = RichTextElement.HeaderLevel(styles: ["HEADING_1"])
    #expect(level == .one)
  }

  @Test("Parses single valid heading style: HEADING_4")
  func parsesSingleValidHeading4() async throws {
    let level = RichTextElement.HeaderLevel(styles: ["HEADING_4"])
    #expect(level == .four)
  }

  @Test("Returns first matching header when multiple styles present")
  func returnsFirstMatchingHeader() async throws {
    // Contains a non-header first, then a valid header
    let level1 = RichTextElement.HeaderLevel(styles: ["STRONG", "HEADING_2"])
    #expect(level1 == .two)

    // Contains two headers; should pick the first header in order
    let level2 = RichTextElement.HeaderLevel(styles: ["HEADING_3", "HEADING_1"])
    #expect(level2 == .three)
  }

  @Test("Ignores unknown/invalid styles and returns nil if no header present")
  func ignoresInvalidAndReturnsNil() async throws {
    let level = RichTextElement.HeaderLevel(styles: ["STRONG", "EMPHASIS"])
    #expect(level == nil)
  }

  @Test("Is case-sensitive and does not parse lowercase values")
  func caseSensitive() async throws {
    let level = RichTextElement.HeaderLevel(styles: ["heading_1"])
    #expect(level == nil)
  }

  @Test("Returns nil for empty or nil arrays")
  func emptyOrNilArrays() async throws {
    let empty = RichTextElement.HeaderLevel(styles: [])
    #expect(empty == nil)

    let nilArray = RichTextElement.HeaderLevel(styles: nil)
    #expect(nilArray == nil)
  }
}
