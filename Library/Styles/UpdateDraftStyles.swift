import Prelude
import Prelude_UIKit
import UIKit

public let updateDraftCloseBarButtonItemStyle = closeBarButtonItemStyle
  <> UIBarButtonItem.lens.accessibilityHint %~ { _ in "Closes update draft." }

public let updateDraftPreviewBarButtonItemStyle = doneBarButtonItemStyle
  <> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_preview() }

public let updateDraftBackBarButtonItemStyle = plainBarButtonItemStyle
  <> UIBarButtonItem.lens.title %~ { _ in "Back" }

public let updateTitleTextFieldStyle = formFieldStyle
  <> UITextField.lens.font %~ { _ in .ksr_title1(size: 22) }
  <> UITextField.lens.placeholder %~ { _ in Strings.dashboard_post_update_compose_placeholder_title() }
  <> UITextField.lens.returnKeyType .~ .Next
  <> UITextField.lens.textColor .~ .ksr_text_navy_700

public let updateBodyTextViewStyle = UITextView.lens.backgroundColor .~ .clearColor()
  <> UITextView.lens.font %~ { _ in .ksr_callout() }
  <> UITextView.lens.textColor .~ .ksr_text_navy_600
  <> UITextView.lens.textContainerInset .~ .init(top: 34, left: 12, bottom: 12, right: 12)
  <> UITextView.lens.textContainer.lineFragmentPadding .~ 0
  <> UITextView.lens.tintColor .~ .ksr_green_700

public let updateBodyPlaceholderTextViewStyle = updateBodyTextViewStyle
  <> UITextView.lens.text %~ { _ in "Share an update about your project…" }
  <> UITextView.lens.textColor .~ .ksr_text_navy_500
  <> UITextView.lens.userInteractionEnabled .~ false

public let updateBackersOnlyButtonStyle =
  UIButton.lens.contentEdgeInsets .~ .init(top: 0, left: 7, bottom: 0, right: 0)
    <> UIButton.lens.image(forState: .Normal) %~ { _ in image(named: "update-draft-visibility-public-icon") }
    <> UIButton.lens.image(forState: .Selected) %~ { _ in
      image(named: "update-draft-visibility-backers-only-icon")
    }
    <> UIButton.lens.tintColor .~ .ksr_navy_600
    <> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.dashboard_post_update_compose_public_label() }
    <> UIButton.lens.title(forState: .Selected) %~ { _ in
      Strings.dashboard_post_update_compose_private_label()
    }
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_600
    <> UIButton.lens.titleEdgeInsets .~ .init(top: 0, left: 7, bottom: 0, right: 0)
    <> UIButton.lens.titleLabel.font %~ { _ in .ksr_caption1() }

public let updateAddAttachmentButtonStyle =
  UIButton.lens.backgroundColor .~ .ksr_navy_200
    <> UIButton.lens.contentCompressionResistancePriorityForAxis(.Vertical) .~ UILayoutPriorityRequired
    <> UIButton.lens.contentEdgeInsets .~ .init(top: 11, left: 9, bottom: 12, right: 9)
    <> UIButton.lens.contentHuggingPriorityForAxis(.Vertical) .~ UILayoutPriorityRequired
    <> UIButton.lens.image(forState: .Normal) %~ { _ in image(named: "update-draft-add-attachment-icon") }
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_navy_300.CGColor
    <> UIButton.lens.layer.borderWidth .~ 1
    <> UIButton.lens.layer.cornerRadius .~ 8
    <> UIButton.lens.tintColor .~ .ksr_navy_600
    <> UIButton.lens.title(forState: .Normal) .~ nil

public let updateAddAttachmentExpandedButtonStyle =
  UIButton.lens.tintColor .~ .ksr_text_navy_500
    <> UIButton.lens.title(forState: .Normal) %~ { _ in "Add attachments…" }
    <> UIButton.lens.titleLabel.font %~ { _ in .ksr_caption1() }

public let updateAttachmentsScrollViewStyle =
  UIScrollView.lens.showsHorizontalScrollIndicator .~ false

public let updateAttachmentsStackViewStyle =
  UIStackView.lens.spacing .~ 8

public let updateAttachmentsThumbStyle =
  UIImageView.lens.contentMode .~ .ScaleAspectFill
    <> UIImageView.lens.clipsToBounds .~ true
    <> UIImageView.lens.layer.cornerRadius .~ 4
    <> UIImageView.lens.userInteractionEnabled .~ true

public let updatePreviewBarButtonItemStyle =
  doneBarButtonItemStyle
    <> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_publish() }
