import Foundation
import KDS
import KsApi
import Library
import PassKit
import Prelude
import UIKit

final class DesignSystemViewController: UIViewController {
  private lazy var scrollView = { UIScrollView(frame: .zero) }()
  private lazy var rootStackView = { UIStackView(frame: .zero) }()

  // MARK: - Alerts

  private let alertsLabel = UILabel()
  private let alertsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let errorSnackbarStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let errorSnackbarIcon = { UIImageView(frame: .zero) }()
  private let errorSnackbarLabel = UILabel()
  private let confirmationSnackbarStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let confirmationSnackbarIcon = { UIImageView(frame: .zero) }()
  private let confirmationSnackbarLabel = UILabel()

  // MARK: - Buttons

  private let buttonsLabel = UILabel()
  private let buttonsStackView: UIStackView = { UIStackView(frame: .zero) }()

  // MARK: - Icons

  private let iconsLabel = UILabel()
  private let iconsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let logoIcon = { UIImageView(frame: .zero) }()
  private let arrowDownIcon = { UIImageView(frame: .zero) }()
  private let bookmarkIcon = { UIImageView(frame: .zero) }()
  private let heartIcon = { UIImageView(frame: .zero) }()

  // MARK: - Controls

  private let controlsLabel = UILabel()
  private let controlsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let switchControlEnabled = UISwitch(frame: .zero)
  private let switchControlDisabled = UISwitch(frame: .zero)
  private let stepper: UIStepper = { UIStepper(frame: .zero) }()
  private let dropdownButton: UIButton = { UIButton(frame: .zero) }()

  // MARK: - Inputs

  private let inputsLabel = UILabel()
  private let inputsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let emailTextField: UITextField = { UITextField(frame: .zero) }()
  private let passwordTextField: UITextField = { UITextField(frame: .zero) }()

  // MARK: - Progress Indicators

  private let progressLabel = UILabel()
  private let progressStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let loadingIndicator = UIActivityIndicatorView()
  private let pullToRefreshImageView = UIImageView(image: image(named: "icon--refresh-small"))
  private let shimmerLoadingView = DemoShimmerLoadingView(frame: .zero)

  // MARK: - Footers

  private let footersLabel = UILabel()
  private let footersStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var demoCTAContainerView: DemoCTAContainerView = {
    DemoCTAContainerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Typography

  private let typesLabel = UILabel()
  private let typeStackView: UIStackView = { UIStackView(frame: .zero) }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title .~ "System Design"

    self.dropdownButton.setTitle("United States", for: .normal)

    let emailTextFieldpaddingView = UIView(frame: CGRectMake(0, 0, 15, self.emailTextField.frame.height))
    let passTextFieldpaddingView = UIView(frame: CGRectMake(0, 0, 15, self.passwordTextField.frame.height))
    self.emailTextField.leftView = emailTextFieldpaddingView
    self.emailTextField.leftViewMode = .always
    self.passwordTextField.leftView = passTextFieldpaddingView
    self.passwordTextField.leftViewMode = .always

    self.configureViews()
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.scrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (
      [
        self.alertsLabel,
        self.alertsStackView,
        self.buttonsLabel,
        self.buttonsStackView,
        self.iconsLabel,
        self.iconsStackView,
        self.controlsLabel,
        self.controlsStackView,
        self.inputsLabel,
        self.inputsStackView,
        self.progressLabel,
        self.progressStackView,
        self.footersLabel,
        self.footersStackView,
        self.typesLabel,
        self.typeStackView
      ], self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Alerts Stack

    _ = ([self.errorSnackbarIcon, self.errorSnackbarLabel], self.errorSnackbarStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (
      [self.confirmationSnackbarIcon, self.confirmationSnackbarLabel],
      self.confirmationSnackbarStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    _ = (
      [self.errorSnackbarStackView, self.confirmationSnackbarStackView],
      self.alertsStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - New Design System Buttons

    KSRButtonStyle.allCases.forEach { buttonStyle in
      let button = KSRButton(style: buttonStyle)
      button.setTitle("\(String(describing: buttonStyle))", for: .normal)
      self.buttonsStackView.addArrangedSubview(button)

      let buttonDisabled = KSRButton(style: buttonStyle)
      buttonDisabled.setTitle("\(String(describing: buttonStyle)) (disabled)", for: .normal)
      buttonDisabled.isEnabled = false
      self.buttonsStackView.addArrangedSubview(buttonDisabled)

      let twoButtonStack = UIStackView(arrangedSubviews: [button, buttonDisabled])
      twoButtonStack.spacing = 8.0
      self.buttonsStackView.addArrangedSubview(twoButtonStack)

      NSLayoutConstraint.activate([
        twoButtonStack.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor)
      ])
    }

    // MARK: - Icons Stack

    _ = (
      [
        self.arrowDownIcon,
        self.bookmarkIcon,
        self.heartIcon,
        self.logoIcon
      ], self.iconsStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Controls Stack

    _ = (
      [
        self.switchControlEnabled,
        self.switchControlDisabled,
        self.stepper,
        self.dropdownButton
      ], self.controlsStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Inputs

    _ = (
      [
        self.emailTextField,
        self.passwordTextField
      ], self.inputsStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Progress Indicators Stack

    _ = (
      [
        self.loadingIndicator,
        self.pullToRefreshImageView,
        self.shimmerLoadingView
      ], self.progressStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Footers Stack

    _ = ([self.demoCTAContainerView], self.footersStackView)
      |> ksr_addArrangedSubviewsToStackView()

    // MARK: - Typography Stack

    // New Design System Fonts
    InterFont.allCases.forEach { style in
      let label = UILabel()
      label.text = String(describing: style).capitalized
      label.font = style.font()
      label.textColor = LegacyColors.ksr_black.uiColor()
      label.adjustsFontForContentSizeCategory = true
      self.typeStackView.addArrangedSubview(label)

      let labelBold = UILabel()
      labelBold.text = "\(String(describing: style)) Bold".capitalized
      labelBold.font = style.font().bolded
      labelBold.textColor = LegacyColors.ksr_black.uiColor()
      labelBold.adjustsFontForContentSizeCategory = true
      self.typeStackView.addArrangedSubview(labelBold)
    }

    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -4),

      self.errorSnackbarStackView.heightAnchor.constraint(equalToConstant: 64),
      self.errorSnackbarStackView.widthAnchor.constraint(equalToConstant: 351),
      self.confirmationSnackbarStackView.heightAnchor.constraint(equalToConstant: 64),
      self.confirmationSnackbarStackView.widthAnchor.constraint(equalToConstant: 351),
      self.errorSnackbarIcon.widthAnchor.constraint(equalToConstant: 20),
      self.errorSnackbarIcon.heightAnchor.constraint(equalToConstant: 20),
      self.confirmationSnackbarIcon.widthAnchor.constraint(equalToConstant: 20),
      self.confirmationSnackbarIcon.heightAnchor.constraint(equalToConstant: 20),

      self.heartIcon.widthAnchor.constraint(equalToConstant: 20),
      self.heartIcon.heightAnchor.constraint(equalToConstant: 20),
      self.bookmarkIcon.widthAnchor.constraint(equalToConstant: 20),
      self.bookmarkIcon.heightAnchor.constraint(equalToConstant: 20),
      self.arrowDownIcon.widthAnchor.constraint(equalToConstant: 20),
      self.arrowDownIcon.heightAnchor.constraint(equalToConstant: 20),
      self.dropdownButton.widthAnchor.constraint(equalToConstant: 175),

      self.emailTextField.heightAnchor.constraint(equalToConstant: 48),
      self.emailTextField.widthAnchor.constraint(equalTo: self.inputsStackView.widthAnchor),
      self.passwordTextField.heightAnchor.constraint(equalToConstant: 48),
      self.passwordTextField.widthAnchor.constraint(equalTo: self.inputsStackView.widthAnchor),

      self.shimmerLoadingView.leftAnchor.constraint(equalTo: self.progressStackView.leftAnchor),
      self.shimmerLoadingView.rightAnchor.constraint(equalTo: self.progressStackView.rightAnchor),
      self.pullToRefreshImageView.widthAnchor.constraint(equalToConstant: 25),

      self.demoCTAContainerView.leftAnchor.constraint(equalTo: self.footersStackView.leftAnchor),
      self.demoCTAContainerView.rightAnchor.constraint(equalTo: self.footersStackView.rightAnchor),
      self.demoCTAContainerView.bottomAnchor.constraint(equalTo: self.footersStackView.bottomAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ LegacyColors.ksr_white.uiColor()

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true
      |> \.showsVerticalScrollIndicator .~ false

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(3), leftRight: Styles.grid(4))
      |> \.spacing .~ 20

    // MARK: - Alert Styles

    _ = self.errorSnackbarStackView
      |> alertStackViewStyle
      |> \.backgroundColor .~ LegacyColors.ksr_alert.uiColor()

    _ = self.confirmationSnackbarStackView
      |> alertStackViewStyle
      |> \.backgroundColor .~ LegacyColors.ksr_trust_500.uiColor()

    _ = self.alertsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ LegacyColors.ksr_black.uiColor()
      |> \.text .~ "Alerts"

    _ = self.alertsStackView
      |> verticalComponentStackViewStyle

    _ = self.errorSnackbarIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ LegacyColors.ksr_white.uiColor()
      |> UIImageView.lens.image .~ UIImage(named: "fix-icon")?.withRenderingMode(.alwaysTemplate)

    _ = self.errorSnackbarLabel
      |> \.font .~ .ksr_subhead()
      |> \.textColor .~ LegacyColors.ksr_white.uiColor()
      |> \.text .~ "Vestibulum id ligula porta felis euismod semper. Etiam porta sem malesuada."
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 2

    _ = self.confirmationSnackbarIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ LegacyColors.ksr_white.uiColor()
      |> UIImageView.lens.image .~ UIImage(named: "icon--confirmation")?.withRenderingMode(.alwaysTemplate)

    _ = self.confirmationSnackbarLabel
      |> \.font .~ .ksr_subhead()
      |> \.textColor .~ LegacyColors.ksr_white.uiColor()
      |> \.text .~ "Vestibulum id ligula porta felis euismod semper. Etiam porta sem malesuada."
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 2

    // MARK: - Button Styles

    _ = self.buttonsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ LegacyColors.ksr_black.uiColor()
      |> \.text .~ "Buttons"

    _ = self.buttonsStackView
      |> verticalComponentStackViewStyle

    // MARK: - Icon Styles

    _ = self.iconsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ LegacyColors.ksr_black.uiColor()
      |> \.text .~ "Icons"

    _ = self.iconsStackView
      |> verticalComponentStackViewStyle

    _ = self.logoIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ LegacyColors.ksr_create_500.uiColor()
      |> UIImageView.lens.image .~ UIImage(named: "kickstarter-logo")?.withRenderingMode(.alwaysTemplate)

    _ = self.arrowDownIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ LegacyColors.ksr_create_500.uiColor()
      |> UIImageView.lens.image .~ UIImage(named: "arrow-down-large")?.withRenderingMode(.alwaysTemplate)

    _ = self.heartIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ LegacyColors.ksr_support_400.uiColor()
      |> UIImageView.lens.image .~ UIImage(named: "heart-icon")?.withRenderingMode(.alwaysTemplate)

    _ = self.bookmarkIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ LegacyColors.ksr_create_700.uiColor()
      |> UIImageView.lens.image .~ UIImage(named: "icon--bookmark")?.withRenderingMode(.alwaysTemplate)

    // MARK: - Control Styles

    _ = self.controlsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ LegacyColors.ksr_black.uiColor()
      |> \.text .~ "Controls"

    _ = self.controlsStackView
      |> verticalStackViewStyle
      |> \.alignment .~ .leading
      |> \.spacing .~ Styles.grid(1)

    _ = self.controlsStackView
      |> verticalComponentStackViewStyle

    _ = self.switchControlEnabled
      |> adaptiveSwitchControlStyle
      |> \.isOn .~ true

    _ = self.switchControlDisabled
      |> adaptiveSwitchControlStyle
      |> \.isOn .~ false
    self.switchControlDisabled.isEnabled = false

    _ = self.stepper
      |> checkoutStepperStyle

    _ = self.dropdownButton
      |> adaptiveDropDownButtonStyle
      |> checkoutWhiteBackgroundStyle
      |> checkoutRoundedCornersStyle

    // MARK: - Input Styles

    _ = self.inputsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ LegacyColors.ksr_black.uiColor()
      |> \.text .~ "Inputs"

    _ = self.inputsStackView
      |> verticalComponentStackViewStyle

    _ = self.emailTextField
      |> adaptiveEmailFieldStyle
      |> \.layer.borderColor .~ LegacyColors.ksr_support_500.uiColor().cgColor
      |> \.layer.borderWidth .~ 1
      |> \.layer.cornerRadius .~ 6
      |> \.attributedPlaceholder %~ { _ in
        adaptiveAttributedPlaceholder(Strings.login_placeholder_email())
      }
    _ = self.passwordTextField
      |> adaptiveEmailFieldStyle
      |> \.layer.borderColor .~ LegacyColors.ksr_support_500.uiColor().cgColor
      |> \.layer.borderWidth .~ 1
      |> \.layer.cornerRadius .~ 6
      |> UITextField.lens.secureTextEntry .~ true
      |> \.attributedPlaceholder %~ { _ in
        adaptiveAttributedPlaceholder(Strings.login_placeholder_password())
      }

    // MARK: - Progress Styles

    _ = self.progressLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ LegacyColors.ksr_black.uiColor()
      |> \.text .~ "Progress Indicators"

    _ = self.progressStackView
      |> verticalComponentStackViewStyle

    _ = self.loadingIndicator
      |> adaptiveActivityIndicatorStyle
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIActivityIndicatorView.lens.animating .~ true

    _ = self.pullToRefreshImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    // MARK: - Footer Styles

    _ = self.footersLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ LegacyColors.ksr_black.uiColor()
      |> \.text .~ "Footers"

    // MARK: - Typography Styles

    _ = self.typesLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ LegacyColors.ksr_black.uiColor()
      |> \.text .~ "Typography"

    _ = self.typeStackView
      |> verticalComponentStackViewStyle
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
