import Library
import Prelude
import UIKit

internal protocol DiscoveryOnboardingCellDelegate: class {
  func discoveryOnboardingTappedSignUpLoginButton()
}

internal final class DiscoveryOnboardingCell: UITableViewCell, ValueCell {
  internal weak var delegate: DiscoveryOnboardingCellDelegate?

  @IBOutlet fileprivate weak var loginButton: UIButton!
  @IBOutlet fileprivate weak var logoImageView: UIImageView!
  @IBOutlet fileprivate weak var onboardingTitleLabel: UILabel!
  @IBOutlet fileprivate weak var stackView: UIStackView!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
  }

  internal func configureWith(value: Void) {
  }

  internal override func bindStyles() {
    self
      |> baseTableViewCellStyle()
      |> DiscoveryOnboardingCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(8), leftRight: Styles.grid(30))
          : .init(topBottom: Styles.grid(6), leftRight: layoutMargins.left)
    }

    self.loginButton |> discoveryOnboardingSignUpButtonStyle
    self.logoImageView |> discoveryOnboardingLogoStyle
    self.onboardingTitleLabel |> discoveryOnboardingTitleStyle
    self.stackView |> discoveryOnboardingStackViewStyle
  }

  @objc fileprivate func loginButtonTapped() {
    self.delegate?.discoveryOnboardingTappedSignUpLoginButton()
  }
}
