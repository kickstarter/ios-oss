import Prelude
import Prelude_UIKit
import UIKit

public let commentCellRootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.spacing .~ Styles.grid(3)
}

public let commentBodyTextViewStyle: TextViewStyle = { textView in
  textView
    |> UITextView.lens.isScrollEnabled .~ false
    |> UITextView.lens.textContainerInset .~ UIEdgeInsets.zero
    |> UITextView.lens.textContainer.lineFragmentPadding .~ 0
    |> UITextView.lens.backgroundColor .~ UIColor.ksr_white
    |> \.textColor .~ .ksr_support_700
    |> \.textAlignment .~ .left
    |> \.font .~ UIFont.ksr_callout()
    |> \.adjustsFontForContentSizeCategory .~ true
}
