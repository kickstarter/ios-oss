import Foundation
import KsApi
import Library
import PassKit
import Prelude
import UIKit

final class SystemDesignViewController: UIViewController, NibLoading {
  @IBOutlet var scrollView: UIScrollView!

  // MARK: - Alerts

  @IBOutlet var errorSnackbar: UIView!
  @IBOutlet var confirmationSnackbar: UIView!

  // MARK: - Buttons

  @IBOutlet var buttonsStackView: UIStackView!
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let primaryGreenButton = UIButton(type: .custom)
  private let primaryBlueButton = UIButton(type: .custom)
  private let primaryBlackButton = UIButton(type: .custom)
  private let secondaryGreyButton = UIButton(type: .custom)
  private let secondaryRedButton = UIButton(type: .custom)
  private let secondaryDisabledButton = UIButton(type: .custom)
  private let facebookButton = UIButton(type: .custom)
  private let applePayButton: PKPaymentButton = { PKPaymentButton() }()

  // MARK: - Controls

  @IBOutlet var controlsStackView: UIStackView!
  private let switchControlEnabled = UISwitch(frame: .zero)
  private let switchControlDisabled = UISwitch(frame: .zero)
  private let stepper: UIStepper = { UIStepper(frame: .zero) }()
  // TODO: add a drop down example
  private let needsDropdownLabel = UILabel()

  // MARK: - Inputs

  @IBOutlet var inputsStackView: UIStackView!
  @IBOutlet var emailContainer: UIView!
  @IBOutlet var emailTextField: UITextField!
  @IBOutlet var passwordContainer: UIView!
  @IBOutlet var passwordTextField: UITextField!

  // MARK: - Progress Indicators

  @IBOutlet var progressStackView: UIStackView!
  private let loadingIndicator = UIActivityIndicatorView()
  private let pullToRefreshImageView = UIImageView(image: image(named: "icon--refresh-small"))
  // TODO: shimmer view not showing
  private lazy var shimmerLoadingView: PledgeShippingLocationShimmerLoadingView = {
    PledgeShippingLocationShimmerLoadingView(frame: .zero)
  }()
  
  // MARK: - Footers

  @IBOutlet var footersStackView: UIStackView!
  
  private lazy var pledgeCTAContainerView: PledgeViewCTAContainerView = {
    PledgeViewCTAContainerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  
  // MARK: - Properties

  static func instantiate() -> SystemDesignViewController {
    return Storyboard.SystemDesign.instantiate(SystemDesignViewController.self)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title .~ "System Design"

    self.configureViews()
  }

  // MARK: - Configuration

  private func configureViews() {
    // MARK: - Button Stack

    _ = (
      [
        self.primaryGreenButton,
        self.primaryBlueButton,
        self.primaryBlackButton,
        self.secondaryGreyButton,
        self.secondaryDisabledButton,
        self.secondaryRedButton,
        self.facebookButton,
        self.applePayButton
      ], self.buttonsStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Controls Stacks

    _ = (
      [
        self.switchControlEnabled,
        self.switchControlDisabled,
        self.stepper,
        self.needsDropdownLabel
      ], self.controlsStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Progress Indicators

    _ = (
      [
        self.shimmerLoadingView,
        self.loadingIndicator,
        self.pullToRefreshImageView
      ], self.progressStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Footers

    _ = ([self.pledgeCTAContainerView], self.footersStackView)
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint.activate([
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
      self.pullToRefreshImageView.widthAnchor.constraint(equalToConstant: 25),
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.footersStackView.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.footersStackView.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.footersStackView.bottomAnchor),
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true

    // MARK: - Button Styles

    _ = self.primaryGreenButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Green Button"

    _ = self.primaryBlueButton
      |> blueButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Blue Button"

    _ = self.primaryBlackButton
      |> blackButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Black Button"

    _ = self.secondaryGreyButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Secondary Grey Button"

    _ = self.secondaryDisabledButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Secondary Disabled Button"
      |> UIButton.lens.isEnabled .~ false

    _ = self.secondaryRedButton
      |> redButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Secondary Red Button"

    _ = self.facebookButton
      |> facebookButtonStyle
      |> UIButton.lens.title(for: .normal) .~ Strings.Continue_with_Facebook()

    _ = self.applePayButton
      |> applePayButtonStyle

    // MARK: - Control Styles

    _ = self.switchControlEnabled
      |> baseSwitchControlStyle
      |> \.isOn .~ true

    _ = self.switchControlDisabled
      |> baseSwitchControlStyle
      |> \.isOn .~ false
    self.switchControlDisabled.isEnabled = false

    _ = self.stepper
      |> checkoutStepperStyle

    _ = self.needsDropdownLabel
      |> \.text %~ { _ in "Still need to add a dropdown example here" }
      |> \.font .~ UIFont.ksr_footnote()
      |> \.textColor .~ .ksr_support_700
      |> \.numberOfLines .~ 0

    // MARK: - Input Styles

    _ = self.emailContainer
      |> \.layer.borderColor .~ UIColor.ksr_support_200.cgColor
      |> \.layer.borderWidth .~ 1
      |> \.layer.cornerRadius .~ 10

    _ = self.passwordContainer
      |> \.layer.borderColor .~ UIColor.ksr_support_200.cgColor
      |> \.layer.borderWidth .~ 1
      |> \.layer.cornerRadius .~ 10

    _ = self.emailTextField |> emailFieldAutoFillStyle
    _ = self.passwordTextField |> passwordFieldAutoFillStyle

    // MARK: - Progress

    _ = self.loadingIndicator
      |> baseActivityIndicatorStyle
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIActivityIndicatorView.lens.animating .~ true

    _ = self.pullToRefreshImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }
}

private func attributedTermsText() -> NSAttributedString? {
  let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl

  guard
    let termsOfUseLink = HelpType.terms.url(withBaseUrl: baseUrl)?.absoluteString,
    let privacyPolicyLink = HelpType.privacy.url(withBaseUrl: baseUrl)?.absoluteString,
    let cookiePolicyLink = HelpType.cookie.url(withBaseUrl: baseUrl)?.absoluteString
  else { return nil }

  let string = Strings.By_pledging_you_agree_to_Kickstarters_Terms_of_Use_Privacy_Policy_and_Cookie_Policy(
    terms_of_use_link: termsOfUseLink,
    privacy_policy_link: privacyPolicyLink,
    cookie_policy_link: cookiePolicyLink
  )

  return checkoutAttributedLink(with: string)
}
