import Prelude
import Prelude_UIKit
import UIKit

public let updateDraftCloseBarButtonItemStyle = closeBarButtonItemStyle
  <> UIBarButtonItem.lens.accessibilityHint %~ { _ in "Closes update draft." }

public let updateDraftPreviewBarButtonItemStyle = doneBarButtonItemStyle
  <> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_preview() }

public let updateTitleTextFieldStyle = formFieldStyle
  <> UITextField.lens.font %~ { _ in .ksr_title1(size: 22) }
  <> UITextField.lens.placeholder %~ { _ in Strings.dashboard_post_update_compose_placeholder_title() }
  <> UITextField.lens.returnKeyType .~ .next
  <> UITextField.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()

public let updateBodyTextViewStyle = UITextView.lens.backgroundColor .~ .clear
  <> UITextView.lens.font %~ { _ in .ksr_callout() }
  <> UITextView.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
  <> UITextView.lens.textContainerInset .~ .init(top: 34, left: 12, bottom: 12, right: 12)
  <> UITextView.lens.textContainer.lineFragmentPadding .~ 0
  <> UITextView.lens.tintColor .~ LegacyColors.ksr_create_700.uiColor()

public let updateBodyPlaceholderTextViewStyle = updateBodyTextViewStyle
  <> UITextView.lens.text %~ { _ in Strings.Share_an_update_about_your_project() }
  <> UITextView.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
  <> UITextView.lens.isUserInteractionEnabled .~ false

public let updateBackersOnlyButtonStyle =
  UIButton.lens.contentEdgeInsets .~ .init(top: 0, left: 7, bottom: 0, right: 0)
    <> UIButton.lens.image(for: .normal) %~ { _ in image(named: "update-draft-visibility-public-icon") }
    <> UIButton.lens.image(for: .selected) %~ { _ in
      image(named: "update-draft-visibility-backers-only-icon")
    }

    <> UIButton.lens.tintColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_post_update_compose_public_label() }
    <> UIButton.lens.title(for: .selected) %~ { _ in
      Strings.dashboard_post_update_compose_private_label()
    }

    <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_support_400.uiColor()
    <> UIButton.lens.titleEdgeInsets .~ .init(top: 0, left: 7, bottom: 0, right: 0)
    <> UIButton.lens.titleLabel.font %~ { _ in .ksr_caption1() }

public let updateAddAttachmentButtonStyle =
  UIButton.lens.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()
    <> UIButton.lens.contentCompressionResistancePriority(for: .vertical) .~ .required
    <> UIButton.lens.contentEdgeInsets .~ .init(top: 11, left: 9, bottom: 12, right: 9)
    <> UIButton.lens.contentHuggingPriority(for: .vertical) .~ .required
    <> UIButton.lens.image(for: .normal) %~ { _ in image(named: "update-draft-add-attachment-icon") }
    <> UIButton.lens.layer.borderColor .~ LegacyColors.ksr_support_300.uiColor().cgColor
    <> UIButton.lens.layer.borderWidth .~ 1
    <> UIButton.lens.layer.cornerRadius .~ 8
    <> UIButton.lens.tintColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UIButton.lens.title(for: .normal) .~ nil

public let updateAddAttachmentExpandedButtonStyle =
  UIButton.lens.tintColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UIButton.lens.title(for: .normal) %~ { _ in
      Strings.dashboard_post_update_compose_attachment_buttons_add_attachment()
    }

    <> UIButton.lens.titleLabel.font %~ { _ in .ksr_caption1() }

public let updateAttachmentsScrollViewStyle =
  UIScrollView.lens.showsHorizontalScrollIndicator .~ false

public let updateAttachmentsStackViewStyle =
  UIStackView.lens.spacing .~ 8

public let updateAttachmentsThumbStyle =
  UIImageView.lens.contentMode .~ .scaleAspectFill
    <> UIImageView.lens.clipsToBounds .~ true
    <> UIImageView.lens.layer.cornerRadius .~ 4
    <> UIImageView.lens.isUserInteractionEnabled .~ true

public let updatePreviewBarButtonItemStyle =
  doneBarButtonItemStyle
    <> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_publish() }
