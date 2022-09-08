import Foundation
import Library
import Prelude
import UIKit

final class SettingsAccountHeaderView: UIView {
  private lazy var appleIdLabel = { UILabel(frame: .zero) }()
  private lazy var emailLabel = { UILabel(frame: .zero) }()
  private lazy var manageThisAccountLabel = {
    UILabel(frame: .zero)
      |> UILabel.lens.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> UIStackView.lens.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupViews()
    self.setupConstraints()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with email: String) {
    _ = self.emailLabel
      |> \.text .~ email
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_support_100
      |> settingsHeaderContentViewStyle

    _ = self.rootStackView
      |> stackViewStyle

    _ = self.appleIdLabel
      |> appleIdLabelStyle

    _ = self.emailLabel
      |> emailLabelStyle

    _ = self.manageThisAccountLabel
      |> manageThisAccountLabelStyle
  }

  private func setupViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()

    _ = ([self.appleIdLabel, self.emailLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.manageThisAccountLabel, self)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    let margins = self.layoutMarginsGuide

    NSLayoutConstraint.activate([
      self.rootStackView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.rootStackView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.rootStackView.topAnchor.constraint(equalTo: margins.topAnchor),
      self.manageThisAccountLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
      self.manageThisAccountLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
      self.manageThisAccountLabel.topAnchor.constraint(
        equalTo: self.rootStackView.bottomAnchor,
        constant: Styles.grid(2)
      ),
      self.manageThisAccountLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
    ])
  }
}

// MARK: - Styles

private let appleIdLabelStyle: LabelStyle = { label in
  label
    |> settingsTitleLabelStyle
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text %~ { _ in Strings.Apple_ID() }
}

private let emailLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.font .~ .ksr_subhead()
    |> \.textColor .~ .ksr_support_400
}

private let manageThisAccountLabelStyle: LabelStyle = { label in
  label
    |> settingsDescriptionLabelStyle
    |> \.text %~ { _ in Strings.Manage_this_account() }
}

private let stackViewStyle: StackViewStyle = { stackView in
  stackView
    |> ksr_setBackgroundColor(UIColor.ksr_white)
    |> verticalStackViewStyle
    |> \.alignment .~ .leading
    |> \.spacing .~ Styles.grid(1)
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
