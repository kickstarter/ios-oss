import Prelude
import Prelude_UIKit
import UIKit

public let commentCellRootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(1))
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
    |> \.isEditable .~ false
    |> \.isUserInteractionEnabled .~ false
}

public let creatorAuthorBadgeStyle: PaddingLabelStyle = { label in
  label
    |> \.text .~ Strings.Creator()
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_create_700
    |> \.backgroundColor .~ UIColor.ksr_create_700.withAlphaComponent(0.06)
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.adjustsFontForContentSizeCategory .~ true
}

// TODO: Internationalized in the near future.

public let superbackerAuthorBadgeStyle: PaddingLabelStyle = { label in
  label
    |> \.text .~ localizedString(key: "Superbacker", defaultValue: "SUPERBACKER")
    |> \.font .~ UIFont.ksr_headline(size: 10)
    |> \.textColor .~ UIColor.ksr_celebrate_500
    |> \.insets .~ .zero
    |> \.adjustsFontForContentSizeCategory .~ true
}

// TODO: Internationalized in the near future.

public let youAuthorBadgeStyle: PaddingLabelStyle = { label in
  label
    |> \.text .~ localizedString(key: "You_tag_for_comment_author", defaultValue: "You")
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_trust_700
    |> \.backgroundColor .~ UIColor.ksr_trust_100
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.adjustsFontForContentSizeCategory .~ true
}

public let defaultAuthorBadgeStyle: PaddingLabelStyle = { $0 }
