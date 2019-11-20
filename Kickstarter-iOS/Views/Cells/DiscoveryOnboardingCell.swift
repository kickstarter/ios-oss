import Library
import Prelude
import UIKit

internal protocol DiscoveryOnboardingCellDelegate: AnyObject {
  func discoveryOnboardingTappedSignUpLoginButton()
}

internal final class DiscoveryOnboardingCell: UITableViewCell, ValueCell {
  internal weak var delegate: DiscoveryOnboardingCellDelegate?

  @IBOutlet fileprivate var loginButton: UIButton!
  @IBOutlet fileprivate var logoImageView: UIImageView!
  @IBOutlet fileprivate var onboardingTitleLabel: UILabel!
  @IBOutlet fileprivate var stackView: UIStackView!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.loginButton.addTarget(self, action: #selector(self.loginButtonTapped), for: .touchUpInside)
  }

  internal func configureWith(value _: Void) {}

  internal override func bindStyles() {
    _ = self
      |> baseTableViewCellStyle()
      |> DiscoveryOnboardingCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? UIEdgeInsets.init(top: Styles.grid(5), left: Styles.grid(30), bottom: 0, right: Styles.grid(30))
          : UIEdgeInsets.init(top: Styles.grid(3), left: layoutMargins.left, bottom: 0,
                              right: layoutMargins.left)
      }

    _ = self.loginButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.discovery_onboarding_buttons_signup_or_login()
      }

    _ = self.logoImageView |> discoveryOnboardingLogoStyle
    _ = self.onboardingTitleLabel |> discoveryOnboardingTitleStyle
    _ = self.stackView |> discoveryOnboardingStackViewStyle
  }

  @objc fileprivate func loginButtonTapped() {
    self.delegate?.discoveryOnboardingTappedSignUpLoginButton()
  }
}
