import Library
import Prelude
import UIKit

final class CommentInputTextView: UITextView {
  // MARK: - Properties

  let maxHeight: CGFloat = 200 // Product definition

  // MARK: - Lifecycle

  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    if size.height > self.maxHeight {
      size.height = self.maxHeight
      self.isScrollEnabled = true
    } else {
      self.isScrollEnabled = false
    }
    return size
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> inputTextViewStyle
      |> \.tintColor .~ UIColor.ksr_create_700
    self.tintColorDidChange()
  }
}

private let inputTextViewStyle: TextViewStyle = { textView in
  textView
    |> \.showsVerticalScrollIndicator .~ false
    |> \.textContainerInset .~ .init(top: 0, left: -4, bottom: 0, right: 0)
    |> \.font .~ UIFont.ksr_body(size: 15)
    |> \.backgroundColor .~ UIColor.clear
    |> \.textColor .~ UIColor.ksr_black
    |> \.adjustsFontForContentSizeCategory .~ true
}
