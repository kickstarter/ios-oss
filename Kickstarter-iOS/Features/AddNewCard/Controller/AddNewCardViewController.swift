import KsApi
import Library
import Prelude
import ReactiveSwift
import Stripe
import UIKit

internal protocol AddNewCardViewControllerDelegate: AnyObject {
  func addNewCardViewController(
    _ viewController: AddNewCardViewController,
    didAdd newCard: UserCreditCards.CreditCard,
    withMessage message: String
  )
  func addNewCardViewControllerDismissed(_ viewController: AddNewCardViewController)
}

internal final class AddNewCardViewController: UIViewController,
  STPPaymentCardTextFieldDelegate, MessageBannerViewControllerPresenting {
  internal weak var delegate: AddNewCardViewControllerDelegate?

  @IBOutlet private var cardholderNameLabel: UILabel!
  @IBOutlet private var cardholderNameTextField: UITextField!
  @IBOutlet private var creditCardTextField: STPPaymentCardTextField!
  @IBOutlet private var creditCardValidationErrorContainer: UIView!
  @IBOutlet private var creditCardValidationErrorLabel: UILabel!
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var stackView: UIStackView!
  @IBOutlet private var zipcodeView: SettingsFormFieldView!

  private var saveButtonView: LoadingBarButtonItemView!

  internal var messageBannerViewController: MessageBannerViewController?

  fileprivate let viewModel: AddNewCardViewModelType = AddNewCardViewModel()

  internal static func instantiate() -> AddNewCardViewController {
    return Storyboard.Settings.instantiate(AddNewCardViewController.self)
  }

  func configure(with intent: AddNewCardIntent, project: Project? = nil) {
    self.viewModel.inputs.configure(with: intent, project: project)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.cardholderNameTextField.addTarget(
      self,
      action: #selector(self.cardholderNameTextFieldReturn),
      for: .editingDidEndOnExit
    )

    self.cardholderNameTextField.addTarget(
      self,
      action: #selector(self.cardholderNameTextFieldChanged(_:)),
      for: [.editingDidEndOnExit, .editingChanged]
    )

    let cancelButton = UIBarButtonItem(
      title: Strings.Cancel(),
      style: .plain,
      target: self,
      action: #selector(self.cancelButtonTapped)
    )
    cancelButton.tintColor = .ksr_create_700
    self.navigationItem.leftBarButtonItem = cancelButton

    self.saveButtonView = LoadingBarButtonItemView.instantiate()
    self.saveButtonView.setTitle(title: Strings.Save())
    self.saveButtonView.addTarget(self, action: #selector(self.saveButtonTapped))

    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

    self.zipcodeView.textField.addTarget(
      self, action: #selector(zipcodeTextFieldDoneEditing),
      for: .editingDidEndOnExit
    )

    self.zipcodeView.textField.addTarget(
      self, action: #selector(zipcodeTextFieldChanged(textField:)),
      for: .editingChanged
    )

    self.creditCardTextField.delegate = self
    // FIXME: Stripe should handle zip codes for us, but we will be deprecating this view controller in the near future so this setting is a shortcut to use with our existing zip code view.
    self.creditCardTextField.postalCodeEntryEnabled = false

    self.configureRememberThisCardToggleViewController()

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle

    _ = self.cardholderNameLabel
      |> settingsTitleLabelStyle
      |> cardholderNameLabelStyle

    _ = self.cardholderNameTextField
      |> formFieldStyle
      |> cardholderNameTextFieldStyle
      |> \.accessibilityLabel .~ self.cardholderNameLabel.text

    _ = self.creditCardTextField
      |> creditCardTextFieldStyle

    _ = self.creditCardValidationErrorLabel
      |> settingsDescriptionLabelStyle
      |> \.textColor .~ .ksr_alert

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true

    _ = self.zipcodeView.titleLabel
      |> \.text %~ { _ in
        localizedPostalCode()
      }

    _ = self.zipcodeView
      |> \.autocapitalizationType .~ .allCharacters
      |> \.returnKeyType .~ .done

    _ = self.rememberThisCardToggleViewController.titleLabel
      |> \.text %~ { _ in Strings.Remember_this_card() }

    _ = self.rememberThisCardToggleViewController.toggle
      |> \.accessibilityLabel %~ { _ in Strings.Remember_this_card() }

    _ = [
      self.rememberThisCardToggleViewControllerContainer,
      self.rememberThisCardToggleViewController.view
    ]
    .compact()
    ||> \.backgroundColor .~ UIColor.ksr_white
  }

  override func bindViewModel() {
    super.bindViewModel()
    self.creditCardValidationErrorLabel.rac.text = self.viewModel.outputs.unsupportedCardBrandErrorText

    self.rememberThisCardToggleViewControllerContainer.rac.hidden =
      self.viewModel.outputs.rememberThisCardToggleViewControllerContainerIsHidden

    self.viewModel.outputs.rememberThisCardToggleViewControllerIsOn
      .observeValues { [weak self] isOn in
        self?.rememberThisCardToggleViewController.toggle.isOn = isOn
      }

    self.creditCardValidationErrorContainer.rac.hidden =
      self.viewModel.outputs.creditCardValidationErrorContainerHidden
    self.cardholderNameTextField.rac.becomeFirstResponder =
      self.viewModel.outputs.cardholderNameBecomeFirstResponder

    self.viewModel.outputs.creditCardValidationErrorContainerHidden
      .filter(isFalse)
      .observeForUI()
      .observeValues { _ in
        UIAccessibility.post(
          notification: .layoutChanged,
          argument: self.creditCardValidationErrorLabel
        )
      }

    self.viewModel.outputs.paymentDetailsBecomeFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.creditCardTextField.becomeFirstResponder()
      }

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] isEnabled in
        self?.saveButtonView.setIsEnabled(isEnabled: isEnabled)
      }

    self.viewModel.outputs.setStripePublishableKey
      .observeForUI()
      .observeValues {
        STPAPIClient.shared.publishableKey = $0
      }

    self.viewModel.outputs.newCardAddedWithMessage
      .observeForUI()
      .observeValues { [weak self] newCard, message in
        guard let self = self else { return }
        self.delegate?.addNewCardViewController(self, didAdd: newCard, withMessage: message)
      }

    self.viewModel.outputs.dismissKeyboard
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.dismissKeyboard()
      }

    self.viewModel.outputs.paymentDetails
      .observeForUI()
      .observeValues { [weak self] paymentDetails in
        self?.createStripeToken(with: paymentDetails)
      }

    self.viewModel.outputs.activityIndicatorShouldShow
      .observeForUI()
      .observeValues { [weak self] shouldShow in
        if shouldShow {
          self?.saveButtonView.startAnimating()
        } else {
          self?.saveButtonView.stopAnimating()
        }
      }

    self.viewModel.outputs.addNewCardFailure
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
      }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change)
      }
  }

  @objc fileprivate func cancelButtonTapped() {
    self.delegate?.addNewCardViewControllerDismissed(self)
  }

  @objc fileprivate func saveButtonTapped() {
    self.viewModel.inputs.saveButtonTapped()
  }

  @objc func cardholderNameTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.cardholderNameChanged(textField.text)
  }

  @objc func cardholderNameTextFieldReturn(_: UITextField) {
    self.viewModel.inputs.cardholderNameTextFieldReturn()
  }

  // MARK: - Functions

  private func configureRememberThisCardToggleViewController() {
    self.rememberThisCardToggleViewController.willMove(toParent: self)
    self.addChild(self.rememberThisCardToggleViewController)

    _ = (self.rememberThisCardToggleViewController.view, self.rememberThisCardToggleViewControllerContainer)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    self.rememberThisCardToggleViewController.didMove(toParent: self)

    self.stackView.addArrangedSubview(self.rememberThisCardToggleViewControllerContainer)

    let topSeparator = UIView(frame: .zero)
    let bottomSeparator = UIView(frame: .zero)

    _ = [topSeparator, bottomSeparator]
      ||> \.translatesAutoresizingMaskIntoConstraints .~ false
      ||> \.backgroundColor .~ .ksr_support_300

    self.rememberThisCardToggleViewControllerContainer.addSubview(topSeparator)
    self.rememberThisCardToggleViewControllerContainer.addSubview(bottomSeparator)

    NSLayoutConstraint.activate([
      topSeparator.leftAnchor
        .constraint(equalTo: self.rememberThisCardToggleViewControllerContainer.leftAnchor),
      topSeparator.topAnchor
        .constraint(equalTo: self.rememberThisCardToggleViewControllerContainer.topAnchor),
      topSeparator.rightAnchor
        .constraint(equalTo: self.rememberThisCardToggleViewControllerContainer.rightAnchor),
      topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
      bottomSeparator.leftAnchor
        .constraint(equalTo: self.rememberThisCardToggleViewControllerContainer.leftAnchor),
      bottomSeparator.bottomAnchor
        .constraint(equalTo: self.rememberThisCardToggleViewControllerContainer.bottomAnchor),
      bottomSeparator.rightAnchor
        .constraint(equalTo: self.rememberThisCardToggleViewControllerContainer.rightAnchor),
      bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5)
    ])

    self.rememberThisCardToggleViewControllerContainer.heightAnchor
      .constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
      .isActive = true

    self.rememberThisCardToggleViewController.toggle.addTarget(
      self,
      action: #selector(AddNewCardViewController.rememberThisCardToggled(_:)),
      for: .valueChanged
    )
  }

  private func createStripeToken(with paymentDetails: PaymentDetails) {
    let cardParams = STPCardParams()
    cardParams.name = paymentDetails.cardholderName
    cardParams.number = paymentDetails.cardNumber
    cardParams.expMonth = UInt(truncating: paymentDetails.expMonth)
    cardParams.expYear = UInt(truncating: paymentDetails.expYear)
    cardParams.cvc = paymentDetails.cvc
    cardParams.address.postalCode = paymentDetails.postalCode

    STPAPIClient.shared.createToken(withCard: cardParams) { token, error in
      if let token = token {
        self.viewModel.inputs.stripeCreated(token.tokenId, stripeID: token.stripeID)
      } else {
        self.viewModel.inputs.stripeError(error)
      }
    }
  }

  private func dismissKeyboard() {
    [self.cardholderNameTextField, self.creditCardTextField, self.zipcodeView.textField]
      .forEach { $0?.resignFirstResponder() }
  }

  // MARK: - Actions

  @objc private func rememberThisCardToggled(_ sender: UISwitch) {
    self.viewModel.inputs.rememberThisCardToggleChanged(to: sender.isOn)
  }

  // MARK: - Subviews

  private lazy var rememberThisCardToggleViewControllerContainer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rememberThisCardToggleViewController: ToggleViewController = {
    ToggleViewController(nibName: nil, bundle: nil)
  }()
}

// MARK: - Zipcode UITextField Delegate

extension AddNewCardViewController {
  @objc internal func zipcodeTextFieldDoneEditing() {
    self.viewModel.inputs.zipcodeTextFieldDidEndEditing()
  }

  @objc internal func zipcodeTextFieldChanged(textField: UITextField) {
    self.viewModel.inputs.zipcodeChanged(zipcode: textField.text)
  }
}

// MARK: - STPPaymentCardTextFieldDelegate

extension AddNewCardViewController {
  internal func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
    self.viewModel.inputs.paymentInfo(isValid: textField.isValid)

    guard let cardnumber = textField.cardNumber else {
      return
    }

    let stpCardBrand = STPCardValidator.brand(forNumber: cardnumber)
    let expirationMonth = NSNumber(integerLiteral: textField.expirationMonth)
    let expirationYear = NSNumber(integerLiteral: textField.expirationYear)

    self.viewModel.inputs.creditCardChanged(cardDetails: (
      cardnumber, expirationMonth, expirationYear, textField.cvc, stpCardBrand.creditCardType
    ))
  }
}

// MARK: - Styles

private let cardholderNameLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.isAccessibilityElement .~ false
    |> \.text %~ { _ in Strings.Cardholder_name() }
}

private let cardholderNameTextFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.autocapitalizationType .~ .words
    |> \.returnKeyType .~ .next
    |> \.textAlignment .~ .right
    |> \.textColor .~ .ksr_support_400
    |> \.attributedPlaceholder .~ NSAttributedString(
      string: Strings.Name(),
      attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400]
    )
}

private typealias PaymentCardTextFieldStyle = (STPPaymentCardTextField) -> STPPaymentCardTextField

private let creditCardTextFieldStyle: PaymentCardTextFieldStyle = { (textField: STPPaymentCardTextField) in
  textField
    |> \.borderColor .~ nil
    |> \.font .~ .ksr_body()
    |> \.textColor .~ .ksr_support_400
    |> \.textErrorColor .~ .ksr_alert
    |> \.cursorColor .~ .ksr_create_700
    |> \.placeholderColor .~ .ksr_support_400
}
