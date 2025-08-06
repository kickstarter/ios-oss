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

  internal override func bindStyles() {}

  @objc fileprivate func loginButtonTapped() {
    self.delegate?.discoveryOnboardingTappedSignUpLoginButton()
  }
}

// MARK: - Styles

private let discoveryOnboardingTitleStyle: LabelStyle = { label in
  label
    |> \.font .~ .ksr_title3()
    |> \.backgroundColor .~ .clear
    |> \.textAlignment .~ .center
    |> \.numberOfLines .~ 2
    |> \.text %~ { _ in Strings.discovery_onboarding_title_bring_creative_projects_to_life() }
    |> \.textColor .~ Colors.Text.primary.uiColor()
}

private let discoveryOnboardingLogoStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleAspectFit
    |> \.tintColor .~ Colors.Brand.logo.uiColor()
    |> \.backgroundColor .~ .clear
    |> UIImageView.lens.contentHuggingPriority(for: .vertical) .~ .required
    |> UIImageView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required
}

private let discoveryOnboardingStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(3)
    |> \.distribution .~ .fill
    |> \.alignment .~ .fill
}
