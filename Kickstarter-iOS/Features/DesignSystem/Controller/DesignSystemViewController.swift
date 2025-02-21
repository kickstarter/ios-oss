import Foundation
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
  private let primaryGreenButton = UIButton(type: .custom)
  private let primaryBlueButton = UIButton(type: .custom)
  private let primaryBlackButton = UIButton(type: .custom)
  private let secondaryGreyButton = UIButton(type: .custom)
  private let secondaryRedButton = UIButton(type: .custom)
  private let secondaryDisabledButton = UIButton(type: .custom)
  private let facebookButton = UIButton(type: .custom)
  private let applePayButton: PKPaymentButton = { PKPaymentButton() }()

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
  private let title1Label = UILabel()
  private let title1LabelBold = UILabel()
  private let title2Label = UILabel()
  private let title2LabelBold = UILabel()
  private let title3Label = UILabel()
  private let title3LabelBold = UILabel()
  private let headlineLabel = UILabel()
  private let bodyLabel = UILabel()
  private let calloutLabel = UILabel()
  private let calloutLabelBold = UILabel()
  private let subheadlineLabel = UILabel()
  private let subheadlineLabelBold = UILabel()
  private let footnoteLabel = UILabel()
  private let footnoteLabelBold = UILabel()
  private let caption1Label = UILabel()
  private let caption1LabelBold = UILabel()
  private let caption2Label = UILabel()
  private let caption2LabelBold = UILabel()

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

    _ = (
      [
        self.title1Label,
        self.title1LabelBold,
        self.title2Label,
        self.title2LabelBold,
        self.title3Label,
        self.title3LabelBold,
        self.headlineLabel,
        self.bodyLabel,
        self.calloutLabel,
        self.calloutLabelBold,
        self.subheadlineLabel,
        self.subheadlineLabelBold,
        self.footnoteLabel,
        self.footnoteLabelBold,
        self.caption1Label,
        self.caption1Label,
        self.caption2Label,
        self.caption2LabelBold
      ], self.typeStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    // New Design System Fonts
    let newFontHeader = UILabel()
    newFontHeader.font = .ksr_title1().bolded
    newFontHeader.textColor = adaptiveColor(.black)
    newFontHeader.adjustsFontForContentSizeCategory = true
    newFontHeader.text = "New Typography"
    self.typeStackView.addArrangedSubview(newFontHeader)

    InterFont.allCases.forEach { style in
      let label = UILabel()
      label.text = String(describing: style).capitalized
      label.font = style.font()
      label.textColor = adaptiveColor(.black)
      label.adjustsFontForContentSizeCategory = true
      self.typeStackView.addArrangedSubview(label)

      let labelBold = UILabel()
      labelBold.text = "\(String(describing: style)) Bold".capitalized
      labelBold.font = style.font().bolded
      labelBold.textColor = adaptiveColor(.black)
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

      self.primaryGreenButton.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor),
      self.primaryBlueButton.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor),
      self.primaryBlackButton.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor),
      self.secondaryGreyButton.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor),
      self.secondaryRedButton.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor),
      self.secondaryDisabledButton.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor),
      self.facebookButton.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor),
      self.applePayButton.heightAnchor.constraint(equalToConstant: 48),
      self.applePayButton.widthAnchor.constraint(equalTo: self.buttonsStackView.widthAnchor),

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
      |> \.backgroundColor .~ adaptiveColor(.white)

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
      |> \.backgroundColor .~ adaptiveColor(.alert)

    _ = self.confirmationSnackbarStackView
      |> alertStackViewStyle
      |> \.backgroundColor .~ adaptiveColor(.trust500)

    _ = self.alertsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Alerts"

    _ = self.alertsStackView
      |> verticalComponentStackViewStyle

    _ = self.errorSnackbarIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ adaptiveColor(.white)
      |> UIImageView.lens.image .~ UIImage(named: "fix-icon")?.withRenderingMode(.alwaysTemplate)

    _ = self.errorSnackbarLabel
      |> \.font .~ .ksr_subhead()
      |> \.textColor .~ adaptiveColor(.white)
      |> \.text .~ "Vestibulum id ligula porta felis euismod semper. Etiam porta sem malesuada."
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 2

    _ = self.confirmationSnackbarIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ adaptiveColor(.white)
      |> UIImageView.lens.image .~ UIImage(named: "icon--confirmation")?.withRenderingMode(.alwaysTemplate)

    _ = self.confirmationSnackbarLabel
      |> \.font .~ .ksr_subhead()
      |> \.textColor .~ adaptiveColor(.white)
      |> \.text .~ "Vestibulum id ligula porta felis euismod semper. Etiam porta sem malesuada."
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 2

    // MARK: - Button Styles

    _ = self.buttonsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Buttons"

    _ = self.buttonsStackView
      |> verticalComponentStackViewStyle

    _ = self.primaryGreenButton
      |> adaptiveGreenButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Green Button"

    _ = self.primaryBlueButton
      |> adaptiveBlueButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Blue Button"

    _ = self.primaryBlackButton
      |> adaptiveBlackButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Black Button"

    _ = self.secondaryGreyButton
      |> adaptiveGreyButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Secondary Grey Button"

    _ = self.secondaryDisabledButton
      |> adaptiveGreyButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Secondary Disabled Button"
      |> UIButton.lens.isEnabled .~ false

    _ = self.secondaryRedButton
      |> adaptiveRedButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Secondary Red Button"

    _ = self.facebookButton
      |> adaptiveFacebookButtonStyle
      |> UIButton.lens.title(for: .normal) .~ " \(Strings.Continue_with_Facebook())"

    _ = self.applePayButton
      |> applePayButtonStyle

    // MARK: - Icon Styles

    _ = self.iconsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Icons"

    _ = self.iconsStackView
      |> verticalComponentStackViewStyle

    _ = self.logoIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ adaptiveColor(.create500)
      |> UIImageView.lens.image .~ UIImage(named: "kickstarter-logo")?.withRenderingMode(.alwaysTemplate)

    _ = self.arrowDownIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ adaptiveColor(.create500)
      |> UIImageView.lens.image .~ UIImage(named: "arrow-down-large")?.withRenderingMode(.alwaysTemplate)

    _ = self.heartIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ adaptiveColor(.support400)
      |> UIImageView.lens.image .~ UIImage(named: "heart-icon")?.withRenderingMode(.alwaysTemplate)

    _ = self.bookmarkIcon
      |> adaptiveIconImageViewStyle
      |> \.tintColor .~ adaptiveColor(.create700)
      |> UIImageView.lens.image .~ UIImage(named: "icon--bookmark")?.withRenderingMode(.alwaysTemplate)

    // MARK: - Control Styles

    _ = self.controlsLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ adaptiveColor(.black)
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
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Inputs"

    _ = self.inputsStackView
      |> verticalComponentStackViewStyle

    _ = self.emailTextField
      |> adaptiveEmailFieldStyle
      |> \.layer.borderColor .~ adaptiveColor(.support500).cgColor
      |> \.layer.borderWidth .~ 1
      |> \.layer.cornerRadius .~ 6
      |> \.attributedPlaceholder %~ { _ in
        adaptiveAttributedPlaceholder(Strings.login_placeholder_email())
      }
    _ = self.passwordTextField
      |> adaptiveEmailFieldStyle
      |> \.layer.borderColor .~ adaptiveColor(.support500).cgColor
      |> \.layer.borderWidth .~ 1
      |> \.layer.cornerRadius .~ 6
      |> UITextField.lens.secureTextEntry .~ true
      |> \.attributedPlaceholder %~ { _ in
        adaptiveAttributedPlaceholder(Strings.login_placeholder_password())
      }

    // MARK: - Progress Styles

    _ = self.progressLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ adaptiveColor(.black)
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
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Footers"

    // MARK: - Typography Styles

    _ = self.typesLabel
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Typography"

    _ = self.typeStackView
      |> verticalComponentStackViewStyle

    _ = self.title1Label
      |> \.font .~ .ksr_title1()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Title 1"

    _ = self.title1LabelBold
      |> \.font .~ .ksr_title1().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Title 1 Bold"

    _ = self.title2Label
      |> \.font .~ .ksr_title2()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Title 2"

    _ = self.title2LabelBold
      |> \.font .~ .ksr_title2().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Title 2 Bold"

    _ = self.title3Label
      |> \.font .~ .ksr_title3()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Title 3"

    _ = self.title3LabelBold
      |> \.font .~ .ksr_title3().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Title 3 Bold"

    _ = self.headlineLabel
      |> \.font .~ .ksr_headline()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Headline Bold"

    _ = self.bodyLabel
      |> \.font .~ .ksr_body()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Body"

    _ = self.calloutLabel
      |> \.font .~ .ksr_callout()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Callout"

    _ = self.calloutLabelBold
      |> \.font .~ .ksr_callout().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Callout Bold"

    _ = self.subheadlineLabel
      |> \.font .~ .ksr_subhead()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Subheadline"

    _ = self.subheadlineLabelBold
      |> \.font .~ .ksr_subhead().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Subheadline Bold"

    _ = self.footnoteLabel
      |> \.font .~ .ksr_footnote()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Footnote"

    _ = self.footnoteLabelBold
      |> \.font .~ .ksr_footnote().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Footnote Bold"

    _ = self.caption1Label
      |> \.font .~ .ksr_caption1()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Caption 1"

    _ = self.caption1LabelBold
      |> \.font .~ .ksr_caption1().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Caption 1 Bold"

    _ = self.caption2Label
      |> \.font .~ .ksr_caption2()
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Caption 2"

    _ = self.caption2LabelBold
      |> \.font .~ .ksr_caption2().bolded
      |> \.textColor .~ adaptiveColor(.black)
      |> \.text .~ "Caption 2 Bold"
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
