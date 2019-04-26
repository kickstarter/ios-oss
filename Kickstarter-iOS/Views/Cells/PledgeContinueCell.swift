import Foundation
import Library
import Prelude

final class PledgeContinueCell: UITableViewCell, ValueCell {
  private let continueButton = MultiLineButton(type: .custom)

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setupSubviews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value: ()) {}

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_300

    _ = self.contentView
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.continueButton
      |> continueButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        return Strings.Continue()
    }

    _ = self.continueButton.titleLabel
      ?|> continueButtonTitleLabelStyle

  }

  private func setupSubviews() {
    _ = (self.continueButton, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    self.continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(8)).isActive = true
  }
}

// MARK: - Styles

private var continueButtonStyle = { (button: UIButton) -> UIButton in
  button
    |> greenButtonStyle
    |> roundedStyle(cornerRadius: 12)
    |> UIButton.lens.layer.borderWidth .~ 0
    |> UIButton.lens.titleEdgeInsets .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
}

private var continueButtonTitleLabelStyle = { (titleLabel: UILabel?) -> UILabel? in
  _ = titleLabel
    ?|> \.font .~ UIFont.ksr_headline()
    ?|> \.numberOfLines .~ 0

  _ = titleLabel
    ?|> \.textAlignment .~ NSTextAlignment.center
    ?|> \.lineBreakMode .~ NSLineBreakMode.byWordWrapping

  return titleLabel
}
