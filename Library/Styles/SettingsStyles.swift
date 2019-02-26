import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public let settingsSectionButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil

public let settingsArrowViewStyle = UIImageView.lens.tintColor .~ .ksr_dark_grey_400

public let settingsSectionLabelStyle =
  UILabel.lens.textColor .~ .ksr_soft_black
    <> UILabel.lens.font .~ .ksr_subhead()
    <> UILabel.lens.numberOfLines .~ 2

public let settingsTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_soft_black
    <> UILabel.lens.font .~ .ksr_body()

public let settingsDetailLabelStyle = UILabel.lens.font .~ .ksr_body()
  <> UILabel.lens.numberOfLines .~ 1
  <> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
  <> UILabel.lens.lineBreakMode .~ .byTruncatingTail

public let settingsDescriptionLabelStyle = UILabel.lens.font .~ .ksr_body(size: 13)
    <> UILabel.lens.numberOfLines .~ 0
    <> UILabel.lens.textColor .~ .ksr_dark_grey_400
    <> UILabel.lens.lineBreakMode .~ .byWordWrapping

public let settingsFormFieldStyle =
  UITextField.lens.textColor .~ .ksr_text_dark_grey_500

public let settingsEmailFieldAutoFillStyle = emailFieldAutoFillStyle
  <> settingsFormFieldStyle
  <> UITextField.lens.textAlignment .~ .right

public let settingsPasswordFormFieldStyle = passwordFieldStyle
  <> settingsFormFieldStyle
  <> UITextField.lens.textAlignment .~ .right

public let settingsPasswordFormFieldAutoFillStyle = passwordFieldAutoFillStyle
  <> settingsPasswordFormFieldStyle

public let settingsNewPasswordFormFieldAutoFillStyle = newPasswordFieldAutoFillStyle
  <> settingsPasswordFormFieldStyle

public let settingsLogoutButtonStyle = borderButtonStyle
  <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.profile_settings_log_out_button() }

public let settingsSeparatorStyle = UIView.lens.backgroundColor .~ .ksr_grey_500
  <> UIView.lens.accessibilityElementsHidden .~ true

public let settingsNotificationIconButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
    <> UIButton.lens.tintColor .~ .ksr_text_dark_grey_400

public let settingsSwitchStyle = UISwitch.lens.onTintColor .~ .ksr_green_700
  <> UISwitch.lens.tintColor .~ .ksr_grey_300

public let notificationButtonStyle = UIButton.lens.layer.cornerRadius .~ 9
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_300.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.backgroundColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_grey_200
  <> UIButton.lens.backgroundColor(for: .selected) .~ .ksr_grey_200
  <> UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.clipsToBounds .~ true

public let settingsViewControllerStyle = baseControllerStyle()
  <> UIViewController.lens.view.backgroundColor .~ .ksr_grey_200

public let settingsTableViewStyle = UITableView.lens.backgroundColor .~ .ksr_grey_200
  <> UITableView.lens.separatorStyle .~ .none

public func settingsAttributedPlaceholder(_ string: String) -> NSAttributedString {
  return NSAttributedString(
    string: string,
    attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_400]
  )
}

public func settingsContentViewStyle(_ view: UIView) -> UIView {
  return view
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> \.preservesSuperviewLayoutMargins .~ false
}

public func settingsFooterContentViewStyle(_ view: UIView) -> UIView {
  return view
  |> settingsContentViewStyle
  |> \.layoutMargins .~ .init(
    top: Styles.grid(1),
    left: Styles.grid(2),
    bottom: Styles.grid(0),
    right: Styles.grid(2))
}

public func settingsHeaderContentViewStyle(_ view: UIView) -> UIView {
  return view
    |> settingsContentViewStyle
    |> \.layoutMargins .~ .init(
      top: Styles.grid(5),
      left: Styles.grid(2),
      bottom: Styles.grid(2),
      right: Styles.grid(2))
}

public func settingsHeaderFooterLabelBaseStyle(_ label: UILabel) -> UILabel {
  return label
    |> \.font %~ { _ in .ksr_footnote() }
    |> \.numberOfLines .~ 0
}

public func settingsHeaderFooterLabelStyle(_ label: UILabel) -> UILabel {
  return label
    |> \.backgroundColor .~ .ksr_grey_200
    |> \.textColor .~ .ksr_text_dark_grey_500
}

public func settingsLabelStyle(_ label: UILabel) -> UILabel {
  return label
    |> \.backgroundColor .~ .white
    |> \.font %~ { _ in .ksr_body() }
}

public func settingsStackViewStyle(_ stackView: UIStackView) -> UIStackView {
  return stackView
    |> \.axis %~~ { _, stackView in
      stackView.traitCollection.ksr_isAccessibilityCategory() ? .vertical : .horizontal
    }
    |> \.alignment %~~ { _, stackView in
      stackView.traitCollection.ksr_isAccessibilityCategory() ? .leading : .fill
    }
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ 8
}

public func settingsGroupedTableViewStyle(_ tableView: UITableView) -> UITableView {
  let style = tableView
    |> \.allowsSelection .~ false
    |> \.backgroundColor .~ .ksr_grey_200
    |> \.separatorInset .~ .zero

  if #available(iOS 11, *) { } else {
    let estimatedSectionFooterHeight: CGFloat = 44
    let estimatedSectionHeaderHeight: CGFloat = 100
    let estimatedRowHeight: CGFloat = 44
    let height = UITableView.automaticDimension

    return style
      |> \.estimatedSectionFooterHeight .~ estimatedSectionFooterHeight
      |> \.estimatedSectionHeaderHeight .~ estimatedSectionHeaderHeight
      |> \.estimatedRowHeight .~ estimatedRowHeight
      |> \.sectionFooterHeight .~ height
      |> \.sectionHeaderHeight .~ height
      |> \.rowHeight .~ height
  }

  return style
}

public func settingsTextFieldStyle(_ textField: UITextField) -> UITextField {
  return textField
    |> \.backgroundColor .~ .white
    |> \.font %~ { _ in .ksr_body() }
    |> \.textAlignment %~~ { _, stackView in
      stackView.traitCollection.ksr_isAccessibilityCategory() ? .left : .right
  }
}
