import Library
import Prelude
import UIKit

final class CommentInputTextView: UITextView {
  // MARK: - Properties

  let maxHeight: CGFloat = 200

  // MARK: - Lifecycle

  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)

    self.configureView()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    if size.height > self.maxHeight {
      size.height = self.maxHeight
      isScrollEnabled = true
    } else {
      isScrollEnabled = false
    }
    return size
  }

  // MARK: - Views

  public func configureView() {
    _ = self
      |> inputTextViewStyle
      |> \.tintColor .~ UIColor.ksr_create_700
    self.tintColorDidChange()
  }
}

private let inputTextViewStyle: TextViewStyle = { textView in
  textView
    |> \.showsVerticalScrollIndicator .~ false
    |> \.textContainerInset .~ UIEdgeInsets.zero
    |> \.font .~ UIFont.ksr_body(size: 15)
    |> \.backgroundColor .~ UIColor.clear
    |> \.textColor .~ UIColor.ksr_support_700
    |> \.adjustsFontForContentSizeCategory .~ true
}
