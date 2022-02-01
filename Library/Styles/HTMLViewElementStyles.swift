import Prelude
import Prelude_UIKit
import UIKit

public let textViewStyle: TextViewStyle = { textView in
  let t = textView
    |> UITextView.lens.isScrollEnabled .~ false
    |> UITextView.lens.textContainerInset .~ UIEdgeInsets.zero
    |> UITextView.lens.textContainer.lineFragmentPadding .~ 0
    |> UITextView.lens.backgroundColor .~ UIColor.ksr_white
    |> \.textAlignment .~ .left

  let b = t
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.isEditable .~ false
    |> \.isSelectable .~ true
    |> \.isUserInteractionEnabled .~ true
    |> \.dataDetectorTypes .~ .link

  return b
}

public let imageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.clipsToBounds .~ true
    |> \.backgroundColor .~ .ksr_white
    |> \.contentMode .~ .scaleAspectFit
    |> ignoresInvertColorsImageViewStyle
}
