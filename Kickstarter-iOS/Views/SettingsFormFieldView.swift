import Foundation
import Library
import Prelude

public let largeContentSizeCategories: [UIContentSizeCategory] = [.extraLarge,
                                                                .extraExtraLarge,
                                                                .extraExtraLarge,
                                                                .accessibilityLarge,
                                                                .accessibilityExtraLarge,
                                                                .accessibilityExtraExtraLarge,
                                                                .accessibilityExtraExtraExtraLarge]

final class SettingsFormFieldView: UIView, NibLoading {
  //swiftlint:disable private_outlet
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var stackView: UIStackView!

  public static func instantiate() -> SettingsFormFieldView {
    guard let view = SettingsFormFieldView.fromNib(nib: Nib.SettingsFormFieldView) else {
      fatalError("failed to load SettingsFormFieldView from Nib")
    }

    return view
  }

  override func bindStyles() {
    super.bindStyles()

    // TODO: layout margins should be set at the stackview level
    _ = self
      |> \.layoutMargins .~ .init(leftRight: Styles.grid(2))

    _ = self.titleLabel
      |> settingsTitleLabelStyle
      |> \.isAccessibilityElement .~ false

    _ = self.textField
      |> formFieldStyle
      |> \.autocapitalizationType .~ .words
      |> \.textAlignment .~ .right
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.accessibilityLabel .~ self.titleLabel.text


    _ = self.separatorView
      |> separatorStyle
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    if #available(iOS 11.0, *) {
      if self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
        self.configureForContentSizeLarge()
      } else {
        self.configureForContentSizeRegular()
      }
    } else {
      if largeContentSizeCategories.contains(self.traitCollection.preferredContentSizeCategory) {
        self.configureForContentSizeLarge()

      } else {
        self.configureForContentSizeRegular()
      }
    }
  }

  private func configureForContentSizeLarge() {
    _ = self.stackView
      |> \.axis .~ .vertical

    _ = self.titleLabel
      |> \.numberOfLines .~ 0
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.textAlignment .~ .left

  }

  private func configureForContentSizeRegular() {
    _ = self.stackView
      |> \.axis .~ .horizontal

    _ = self.titleLabel
      |> \.numberOfLines .~ 1
      |> \.lineBreakMode .~ .byTruncatingTail
      |> \.textAlignment .~ .right
  }
}
