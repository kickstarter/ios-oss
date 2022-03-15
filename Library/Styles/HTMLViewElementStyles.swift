import Prelude
import Prelude_UIKit
import UIKit

public let textViewStyle: TextViewStyle = { textView in
  let updatedTextView = textView
    |> UITextView.lens.isScrollEnabled .~ false
    |> UITextView.lens.textContainerInset .~ UIEdgeInsets.zero
    |> UITextView.lens.textContainer.lineFragmentPadding .~ 0
    |> UITextView.lens.backgroundColor .~ UIColor.ksr_white
    |> \.textAlignment .~ .left

  let configurableSettingsTextView = updatedTextView
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.isEditable .~ false
    |> \.isSelectable .~ true
    |> \.isUserInteractionEnabled .~ true
    |> \.dataDetectorTypes .~ .link

  return configurableSettingsTextView
}

public let imageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.clipsToBounds .~ true
    |> \.backgroundColor .~ .ksr_white
    |> \.contentMode .~ .scaleAspectFit
    |> ignoresInvertColorsImageViewStyle
}

public let thumbnailImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.clipsToBounds .~ true
    |> \.backgroundColor .~ .ksr_black
    |> \.contentMode .~ .scaleAspectFit
    |> ignoresInvertColorsImageViewStyle
}
