import Prelude
import Prelude_UIKit
import UIKit

public enum CommentCellStyles {
  public enum Content {
    public static let leftIndentWidth: Int = 5
  }
}

public let commentCellIndentedRootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.layoutMargins .~ .init(
      top: Styles.grid(1),
      left: Styles.grid(CommentCellStyles.Content.leftIndentWidth),
      bottom: Styles.grid(3),
      right: Styles.grid(1)
    )
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(3)
}

public let commentCellRootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(1))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.spacing .~ Styles.grid(3)
}

public let commentBodyTextViewStyle: TextViewStyle = { textView in
  let t = textView
    |> UITextView.lens.isScrollEnabled .~ false
    |> UITextView.lens.textContainerInset .~ UIEdgeInsets.zero
    |> UITextView.lens.textContainer.lineFragmentPadding .~ 0
    |> UITextView.lens.backgroundColor .~ UIColor.ksr_white
    |> \.textColor .~ .ksr_support_700
    |> \.textAlignment .~ .left

  let b = t
    |> \.font .~ UIFont.ksr_callout()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.isEditable .~ false
    |> \.isSelectable .~ true
    |> \.isUserInteractionEnabled .~ true
    |> \.dataDetectorTypes .~ .link

  return b
}

public let superbackerAuthorBadgeStyle: PaddingLabelStyle = { label in
  label
    |> \.text .~ Strings.Superbacker().uppercased()
    |> \.font .~ UIFont.ksr_headline(size: 10)
    |> \.textColor .~ UIColor.ksr_celebrate_500
    |> \.backgroundColor .~ .clear
    |> \.insets .~ .zero
    |> \.adjustsFontForContentSizeCategory .~ true
}

public let youAuthorBadgeStyle: PaddingLabelStyle = { label in
  label
    |> \.text .~ Strings.update_comments_you()
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_trust_700
    |> \.backgroundColor .~ UIColor.ksr_trust_100
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.insets .~ UIEdgeInsets(all: Styles.grid(1))
}

public let authorBadgeLabelStyle: PaddingLabelStyle = { label in
  label
    |> \.numberOfLines .~ 1
    |> \.textColor .~ .ksr_create_500
    |> \.textAlignment .~ .left
    |> \.font .~ UIFont.ksr_callout().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
}

public let resetTextStyle: PaddingLabelStyle = { label in
  label
    |> \.text .~ nil
    |> \.backgroundColor .~ .clear
    |> \.insets .~ UIEdgeInsets(all: Styles.grid(1))
}

public let viewRepliesStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.alignment .~ .center
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(1)
    |> \.layer.borderWidth .~ 1
    |> \.layer.borderColor .~ UIColor.ksr_support_200.cgColor
    |> roundedStyle(cornerRadius: 2.0)
}
