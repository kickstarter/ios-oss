import Foundation
import UIKit
import Library
import Prelude

final class SettingsAccountHeaderView: UIView {
  private lazy var appleIdLabel = { UILabel(frame: .zero) }()
  private lazy var emailLabel = { UILabel(frame: .zero) }()
  private lazy var manageThisAccountLabel = {
    UILabel(frame: .zero)
      |> UILabel.lens.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  private lazy var stackView = {
    UIStackView(frame: .zero)
    |> UIStackView.lens.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupViews()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with email: String) {
    _ = self.emailLabel
      |> \.text .~ email
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200
      |> settingsHeaderContentViewStyle

    _ = self.stackView
      |> stackViewStyle

    _ = self.appleIdLabel
      |> appleIdLabelStyle

    _ = self.emailLabel
      |> emailLabelStyle

    _ = self.manageThisAccountLabel
      |> manageThisAccountLabelStyle
  }

  private func setupViews() {
    _ = (self.stackView, self)
      |> ksr_addSubviewToParent()

    _ = ([self.appleIdLabel, self.emailLabel], self.stackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.manageThisAccountLabel, self)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    let margins = self.layoutMarginsGuide

    NSLayoutConstraint.activate([
      self.stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.stackView.topAnchor.constraint(equalTo: margins.topAnchor),
      self.manageThisAccountLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
      self.manageThisAccountLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
      self.manageThisAccountLabel.topAnchor.constraint(equalTo: self.stackView.bottomAnchor,
                                                       constant: Styles.grid(2)),
      self.manageThisAccountLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
    ])
  }
}

// MARK: - Styles

private let appleIdLabelStyle: LabelStyle = { label in
  label
  |> \.lineBreakMode .~ .byWordWrapping
  |> \.numberOfLines .~ 0
  |> \.font .~ .ksr_body()
  |> \.textColor .~ .ksr_soft_black
  |> \.text %~ { _ in localizedString(key: "apple_id", defaultValue: "Apple ID") }
}

private let emailLabelStyle: LabelStyle = { label in
  label
  |> \.lineBreakMode .~ .byWordWrapping
  |> \.numberOfLines .~ 0
  |> \.font .~ .ksr_subhead()
  |> \.textColor .~ .ksr_text_dark_grey_500
}

private let manageThisAccountLabelStyle: LabelStyle = { label in
  label
  |> settingsDescriptionLabelStyle
  |> \.text %~ { _ in localizedString(key: "manage_this_account",
                                      defaultValue: "Manage this account in your Apple ID settings."
    )}
}

private let stackViewStyle: StackViewStyle = { stackView in
  stackView
  |> ksr_setBackgroundColor(UIColor.white)
  |> verticalStackViewStyle
  |> \.alignment .~ .leading
  |> \.spacing .~ Styles.grid(1)
  |> \.layoutMargins .~ .init(all: Styles.grid(2))
  |> \.isLayoutMarginsRelativeArrangement .~ true
}
