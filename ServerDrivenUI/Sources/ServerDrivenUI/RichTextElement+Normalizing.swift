import Foundation

extension Array where Element == RichTextElement {
  /// The server's rich text parser sits on top of an HTML parser, so a `<div>` containing an
  /// inline `<img>` (e.g. `<div>Here's an image: <img /> Isn't it nice?</div>`) is represented
  /// as a single `Text` element whose `children` are `[Text, Photo, Text]`. Our conversion
  /// architecture maps each GraphQL node to exactly one `RichTextElement`, and `TextBlock`
  /// renders a `Text` element as a single attributed string, which can't host a `Photo`. This
  /// splits any such `Text` into standalone sibling elements so the `Photo` renders on its own,
  /// relying on the server's guarantee that this nesting never goes deeper than one level.
  func withNormalizedNestedElements() -> [RichTextElement] {
    self.flatMap { $0.withNormalizedNestedElements() }
  }
}

extension RichTextElement {
  func withNormalizedNestedElements() -> [RichTextElement] {
    guard case let .text(text, header) = self, text.children.contains(where: { $0.isPhoto }) else {
      return [self]
    }

    var elements: [RichTextElement] = []
    var currentChildren: [RichTextElement] = text.text.isEmpty
      ? []
      : [.text(RichTextElement.Text(text: text.text, link: text.link, styles: text.styles), nil)]

    for child in text.children {
      if child.isPhoto {
        elements.append(.text(RichTextElement.Text(text: "", children: currentChildren), header))
        elements.append(child)
        currentChildren = []
      } else {
        currentChildren.append(child)
      }
    }
    elements.append(.text(RichTextElement.Text(text: "", children: currentChildren), header))

    return elements.filter { !$0.isEmptyText }
  }

  private var isPhoto: Bool {
    if case .photo = self { return true }
    return false
  }

  private var isEmptyText: Bool {
    if case let .text(text, _) = self {
      return text.text.isEmpty && text.children.isEmpty
    }
    return false
  }
}
