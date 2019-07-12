import Foundation
import Library
import Prelude

final class PledgeContinueViewController: UIViewController {
  private let continueButton = MultiLineButton(type: .custom)

  init() {
    super.init(nibName: nil)

    self.setupSubviews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_300

    _ = self
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.continueButton
      |> checkoutGreenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.Continue()
      }

    _ = self.continueButton.titleLabel
      ?|> checkoutGreenButtonTitleLabelStyle
  }

  func configureWith(value _: ()) {}

  private func setupSubviews() {
    _ = (self.continueButton, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    self.continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(8)).isActive = true
  }
}
