import KsApi
import Library
import Prelude
import Stripe
import UIKit

internal final class DeprecatedRewardPledgeViewController: UIViewController {
  internal let viewModel: DeprecatedRewardPledgeViewModelType = DeprecatedRewardPledgeViewModel()

  fileprivate var applePayButton = PKPaymentButton()
  @IBOutlet fileprivate var applePayButtonContainerView: UIStackView!
  @IBOutlet fileprivate var cancelPledgeButton: UIButton!
  @IBOutlet fileprivate var cardInnerView: UIView!
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var changePaymentMethodButton: UIButton!
  @IBOutlet fileprivate var continueToPaymentButton: UIButton!
  @IBOutlet fileprivate var conversionLabel: UILabel!
  @IBOutlet fileprivate var countryLabel: UILabel!
  @IBOutlet fileprivate var descriptionLabel: UILabel!
  @IBOutlet fileprivate var descriptionStackView: UIStackView!
  @IBOutlet fileprivate var descriptionTitleLabel: UILabel!
  @IBOutlet fileprivate var disclaimerTextView: UITextView!
  @IBOutlet fileprivate var differentPaymentMethodButton: UIButton!
  @IBOutlet fileprivate var dropDownIconImageView: UIImageView!
  @IBOutlet fileprivate var estimatedDeliveryDateLabel: UILabel!
  @IBOutlet fileprivate var estimatedFulfillmentStackView: UIStackView!
  @IBOutlet fileprivate var estimatedToFulfillLabel: UILabel!
  @IBOutlet fileprivate var fulfillmentAndShippingFooterStackView: UIStackView!
  @IBOutlet fileprivate var itemsStackView: UIStackView!
  @IBOutlet fileprivate var loadingIndicatorView: UIActivityIndicatorView!
  @IBOutlet fileprivate var loadingOverlayView: UIView!
  @IBOutlet fileprivate var managePledgeStackView: UIStackView!
  @IBOutlet fileprivate var middleStackView: UIStackView!
  @IBOutlet fileprivate var minimumAndConversionStackView: UIStackView!
  @IBOutlet fileprivate var minimumPledgeLabel: UILabel!
  @IBOutlet fileprivate var pledgeButtonsStackView: UIStackView!
  @IBOutlet fileprivate var pledgeContainerView: UIView!
  @IBOutlet fileprivate var pledgeCurrencyLabel: UILabel!
  @IBOutlet fileprivate var pledgeInputTitleLabel: UILabel!
  @IBOutlet fileprivate var pledgeInputStackView: UIStackView!
  @IBOutlet fileprivate var pledgeStackView: UIStackView!
  @IBOutlet fileprivate var pledgeTextField: UITextField!
  @IBOutlet fileprivate var projectTitleAndDescriptionStackView: UIStackView!
  @IBOutlet fileprivate var readMoreContainerView: UIView!
  @IBOutlet fileprivate var readMoreGradientView: GradientView!
  @IBOutlet fileprivate var readMoreLabel: UILabel!
  @IBOutlet fileprivate var rootStackView: UIStackView!
  @IBOutlet fileprivate var scrollView: UIScrollView!
  @IBOutlet fileprivate var separatorView: UIView!
  @IBOutlet fileprivate var shippingActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet fileprivate var shippingAmountLabel: UILabel!
  @IBOutlet fileprivate var shippingContainerView: UIView!
  @IBOutlet fileprivate var shippingDestinationButton: UIButton!
  @IBOutlet fileprivate var shippingInputStackView: UIStackView!
  @IBOutlet fileprivate var shippingInputTitleLabel: UILabel!
  @IBOutlet fileprivate var shippingMenuStackView: UIStackView!
  @IBOutlet fileprivate var titleLabel: UILabel!
  @IBOutlet fileprivate var topStackView: UIStackView!
  @IBOutlet fileprivate var updatePledgeButton: UIButton!
  @IBOutlet fileprivate var updateStackView: UIStackView!

  private var sessionStartedObserver: Any?

  internal static func configuredWith(
    project: Project,
    reward: Reward,
    applePayCapable: Bool = PKPaymentAuthorizationViewController.applePayCapable()
  ) -> DeprecatedRewardPledgeViewController {
    let vc = Storyboard.RewardPledge.instantiate(DeprecatedRewardPledgeViewController.self)
    vc.viewModel.inputs.configureWith(project: project, reward: reward, applePayCapable: applePayCapable)
    return vc
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.view.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self, action: #selector(DeprecatedRewardPledgeViewController.pledgedTextFieldDoneEditing)
      )
    )

    self.disclaimerTextView.delegate = self

    self.applePayButtonContainerView.addArrangedSubview(self.applePayButton)

    self.applePayButton.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.applePayButtonTapped),
      for: .touchUpInside
    )
    self.cancelPledgeButton.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.cancelPledgeButtonTapped),
      for: .touchUpInside
    )
    self.changePaymentMethodButton.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.changePaymentMethodButtonTapped),
      for: .touchUpInside
    )
    self.continueToPaymentButton.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.continueWithPaymentButtonTapped),
      for: .touchUpInside
    )
    self.descriptionLabel.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self, action: #selector(DeprecatedRewardPledgeViewController.expandRewardDescriptionTapped)
      )
    )
    self.differentPaymentMethodButton.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.differentPaymentMethodTapped),
      for: .touchUpInside
    )
    self.pledgeTextField.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.pledgedTextFieldChanged),
      for: .editingChanged
    )
    self.pledgeTextField.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.pledgedTextFieldDoneEditing),
      for: [.editingDidEndOnExit, .editingDidEnd]
    )
    self.readMoreContainerView.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self, action: #selector(DeprecatedRewardPledgeViewController.expandRewardDescriptionTapped)
      )
    )
    self.shippingDestinationButton.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.shippingButtonTapped),
      for: .touchUpInside
    )
    self.titleLabel.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self, action: #selector(DeprecatedRewardPledgeViewController.expandRewardDescriptionTapped)
      )
    )
    self.updatePledgeButton.addTarget(
      self,
      action: #selector(DeprecatedRewardPledgeViewController.updatePledgeButtonTapped),
      for: .touchUpInside
    )

    self.sessionStartedObserver = NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    self.viewModel.inputs.viewDidLoad()
  }

  override func willMove(toParent parent: UIViewController?) {
    super.willMove(toParent: parent)

    self.viewModel.inputs.willMove(toParent: parent)
  }

  internal override func bindStyles() {
    super.bindStyles()

    if !featureNativeCheckoutIsEnabled() {
      _ = self
        |> baseControllerStyle()
    }

    _ = self
      |> DeprecatedRewardPledgeViewController.lens.view.backgroundColor .~ .ksr_grey_600

    _ = self.applePayButton
      |> applePayButtonStyle
      |> UIButton.lens.accessibilityLabel .~ "Apple Pay"

    _ = self.cancelPledgeButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Cancel_your_pledge() }

    _ = self.cardInnerView
      |> roundedStyle(cornerRadius: 18.0)
      |> UIView.lens.backgroundColor .~ .white

    _ = self.cardView
      |> roundedStyle(cornerRadius: 18.0)
      |> UIView.lens.backgroundColor .~ .clear
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_green_500.withAlphaComponent(0.06).cgColor
      |> UIView.lens.layer.borderWidth .~ 6.0

    _ = self.changePaymentMethodButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Change_payment_method() }

    _ = self.dropDownIconImageView
      |> UIImageView.lens.tintColor .~ UIColor.ksr_dark_grey_400

    _ = self.continueToPaymentButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue_to_payment() }

    _ = self.disclaimerTextView
      |> disclaimerTextViewStyle
      |> UITextView.lens.textAlignment .~ .center
      |> UITextView.lens.textContainerInset .~ .init(
        top: Styles.gridHalf(1),
        left: Styles.grid(6),
        bottom: Styles.gridHalf(1),
        right: Styles.grid(6)
      )

    _ = self.updatePledgeButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Update_pledge() }

    _ = self.conversionLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1().bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_green_500

    _ = self.countryLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ UIColor.ksr_green_500

    _ = self.projectTitleAndDescriptionStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.descriptionTitleLabel
      |> UILabel.lens.font .~ UIFont.ksr_callout().bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_text_dark_grey_400
      |> UILabel.lens.text %~ { _ in Strings.Description() }

    _ = self.descriptionLabel
      |> UILabel.lens.contentMode .~ .topLeft
      |> UILabel.lens.font .~ UIFont.ksr_body()
      |> UILabel.lens.textColor .~ UIColor.ksr_soft_black
      |> UILabel.lens.numberOfLines .~ 3
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail
      |> UILabel.lens.isUserInteractionEnabled .~ true

    _ = self.differentPaymentMethodButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Other_payment_methods() }

    _ = self.estimatedToFulfillLabel
      |> UILabel.lens.font .~ UIFont.ksr_callout().bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_text_dark_grey_400
      |> UILabel.lens.text %~ { _ in Strings.Estimated_delivery() }

    _ = self.estimatedDeliveryDateLabel
      |> UILabel.lens.font .~ UIFont.ksr_callout()
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.estimatedFulfillmentStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.fulfillmentAndShippingFooterStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.itemsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.loadingIndicatorView
      |> baseActivityIndicatorStyle

    _ = self.loadingOverlayView
      |> UIView.lens.backgroundColor .~ UIColor(white: 1.0, alpha: 0.99)

    _ = self.middleStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(4))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.minimumAndConversionStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.minimumPledgeLabel
      |> UILabel.lens.font .~ UIFont.ksr_title3().bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_green_500

    _ = self.projectTitleAndDescriptionStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.readMoreContainerView
      |> UIView.lens.backgroundColor .~ .clear
      |> UIView.lens.isUserInteractionEnabled .~ true

    _ = self.readMoreGradientView.backgroundColor = .clear
    _ = self.readMoreGradientView.startPoint = .zero
    _ = self.readMoreGradientView.endPoint = CGPoint(x: 1, y: 0)

    let gradient: [(UIColor?, Float)] = [
      (UIColor.white.withAlphaComponent(0.0), 0),
      (UIColor.white.withAlphaComponent(1.0), 1)
    ]
    _ = self.readMoreGradientView.setGradient(gradient)

    _ = self.readMoreLabel
      |> UILabel.lens.backgroundColor .~ .white
      |> UILabel.lens.textColor .~ .ksr_green_500
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.text %~ { _ in Strings.ellipsis_more() }

    _ = self.separatorView
      |> separatorStyle

    _ = self.updateStackView
      |> UIStackView.lens.spacing .~ Styles.grid(5)

    _ = self.pledgeButtonsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.pledgeContainerView
      |> UIView.lens.layoutMargins .~ .init(
        top: Styles.grid(2),
        left: Styles.grid(2),
        bottom: Styles.grid(2),
        right: Styles.grid(4)
      )
      |> roundedStyle(cornerRadius: 6)
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_grey_400.cgColor
      |> UIView.lens.layer.borderWidth .~ 2

    _ = self.pledgeCurrencyLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ UIColor.ksr_green_500

    _ = self.pledgeInputStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.pledgeInputTitleLabel
      |> UILabel.lens.font .~ UIFont.ksr_subhead().bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_soft_black
      |> UILabel.lens.text %~ { _ in Strings.Your_pledge_amount() }

    _ = self.pledgeStackView
      |> UIStackView.lens.alignment .~ .firstBaseline
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.pledgeTextField
      |> UITextField.lens.borderStyle .~ .none
      |> UITextField.lens.textColor .~ UIColor.ksr_green_500
      |> UITextField.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UITextField.lens.keyboardType .~ .decimalPad

    _ = self.rootStackView
      |> UIStackView.lens.layoutMargins .~ .init(
        topBottom: Styles.grid(2) + Styles.grid(2),
        leftRight: Styles.grid(2) + 1
      )
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.scrollView
      |> UIScrollView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))
      |> UIScrollView.lens.delaysContentTouches .~ false
      |> UIScrollView.lens.keyboardDismissMode .~ .interactive
      |> \.alwaysBounceVertical .~ true
      |> \.contentInset .~ .init(topBottom: Styles.grid(2))
      |> \.scrollIndicatorInsets .~ .init(topBottom: Styles.grid(2))

    _ = self.shippingActivityIndicatorView
      |> baseActivityIndicatorStyle

    _ = self.shippingAmountLabel
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.contentCompressionResistancePriority(for: .horizontal) .~ UILayoutPriority.required

    _ = self.shippingInputStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.shippingInputTitleLabel
      |> UILabel.lens.font .~ UIFont.ksr_subhead().bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_soft_black
      |> UILabel.lens.text %~ { _ in Strings.Your_shipping_destination() }

    _ = self.shippingMenuStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.isUserInteractionEnabled .~ false

    _ = self.shippingContainerView
      |> UIView.lens.layoutMargins .~ .init(
        top: Styles.grid(2), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(4)
      )
      |> roundedStyle(cornerRadius: 6)
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_grey_400.cgColor
      |> UIView.lens.layer.borderWidth .~ 2

    _ = self.shippingDestinationButton
      |> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_navy_200
      |> UIButton.lens.isAccessibilityElement .~ true
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_shipping_options() }

    _ = self.titleLabel
      |> UILabel.lens.font .~ UIFont.ksr_title2().bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_soft_black
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.isUserInteractionEnabled .~ true

    _ = self.topStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(4))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(3)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.applePayButtonContainerView.rac.hidden = self.viewModel.outputs.applePayButtonHidden
    self.cancelPledgeButton.rac.hidden = self.viewModel.outputs.cancelPledgeButtonHidden
    self.changePaymentMethodButton.rac.hidden = self.viewModel.outputs.changePaymentMethodButtonHidden
    self.continueToPaymentButton.rac.hidden = self.viewModel.outputs.continueToPaymentsButtonHidden
    self.conversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.conversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.countryLabel.rac.text = self.viewModel.outputs.countryLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.descriptionTitleLabel.rac.hidden = self.viewModel.outputs.descriptionTitleLabelHidden
    self.differentPaymentMethodButton.rac.hidden = self.viewModel.outputs.differentPaymentMethodButtonHidden
    self.estimatedDeliveryDateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryDateLabelText
    self.estimatedFulfillmentStackView.rac.hidden
      = self.viewModel.outputs.estimatedFulfillmentStackViewHidden
    self.fulfillmentAndShippingFooterStackView.rac.hidden
      = self.viewModel.outputs.fulfillmentAndShippingFooterStackViewHidden
    self.loadingIndicatorView.rac.animating = self.viewModel.outputs.pledgeIsLoading
    self.loadingOverlayView.rac.hidden = self.viewModel.outputs.loadingOverlayIsHidden
    self.separatorView.rac.hidden = self.viewModel.outputs.managePledgeStackViewHidden
    self.managePledgeStackView.rac.hidden = self.viewModel.outputs.managePledgeStackViewHidden
    self.minimumPledgeLabel.rac.text = self.viewModel.outputs.minimumLabelText
    self.navigationItem.rac.title = self.viewModel.outputs.navigationTitle
    self.pledgeCurrencyLabel.rac.text = self.viewModel.outputs.pledgeCurrencyLabelText
    self.pledgeTextField.rac.text = self.viewModel.outputs.pledgeTextFieldText
    self.readMoreContainerView.rac.hidden = self.viewModel.outputs.readMoreContainerViewHidden
    self.shippingActivityIndicatorView.rac.animating = self.viewModel.outputs.shippingIsLoading
    self.shippingAmountLabel.rac.text = self.viewModel.outputs.shippingAmountLabelText
    self.shippingInputStackView.rac.hidden = self.viewModel.outputs.shippingInputStackViewHidden
    self.titleLabel.rac.hidden = self.viewModel.outputs.titleLabelHidden
    self.titleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.updatePledgeButton.rac.hidden = self.viewModel.outputs.updatePledgeButtonHidden
    self.updateStackView.rac.hidden = self.viewModel.outputs.updateStackViewHidden

    self.viewModel.outputs.goToPaymentAuthorization
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToPaymentAuthorization(request: $0) }

    self.viewModel.outputs.setStripePublishableKey
      .observeForUI()
      .observeValues { STPPaymentConfiguration.shared().publishableKey = $0 }

    self.viewModel.outputs.setStripeAppleMerchantIdentifier
      .observeForUI()
      .observeValues { STPPaymentConfiguration.shared().appleMerchantIdentifier = $0 }

    self.viewModel.outputs.goToShippingPicker
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToShippingPicker(project: $0, shippingRules: $1, selectedShippingRule: $2)
      }

    self.viewModel.outputs.items
      .observeForUI()
      .observeValues { [weak self] in self?.load(items: $0) }

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeValues { [weak self] in self?.dismiss(animated: true, completion: nil) }

    self.viewModel.outputs.expandRewardDescription
      .observeForUI()
      .observeValues { [weak self] in
        self?.descriptionLabel.numberOfLines = 0
        self?.view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
          self?.view.layoutIfNeeded()
        }
      }

    self.viewModel.outputs.itemsContainerHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        UIView.animate(withDuration: 0.2) {
          self?.itemsStackView.isHidden = hidden
        }
      }

    self.viewModel.outputs.goToCheckout
      .observeForControllerAction()
      .observeValues { [weak self] initialRequest, project, reward in
        self?.goToCheckout(initialRequest: initialRequest, project: project, reward: reward)
      }

    self.viewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToLoginTout() }

    self.viewModel.outputs.goToThanks
      .observeForControllerAction()
      .observeValues { [weak self] project in
        generateNotificationSuccessFeedback()

        self?.goToThanks(project: project)
      }

    self.viewModel.outputs.showAlert
      .observeForControllerAction()
      .observeValues { [weak self] message, shouldDismiss in
        guard let _self = self else { return }
        _self.present(
          UIAlertController.alert(
            message: message,
            handler: { _ in
              _self.viewModel.inputs.errorAlertTappedOK(shouldDismiss: shouldDismiss)
            }
          ),
          animated: true,
          completion: nil
        )
      }

    self.viewModel.outputs.goToTrustAndSafety
      .observeForUI()
      .observeValues { [weak self] in self?.goToTrustAndSafety() }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change, insets: .init(topBottom: Styles.grid(2)))
      }
  }

  fileprivate func goToCheckout(
    initialRequest: URLRequest,
    project: Project,
    reward: Reward
  ) {
    let vc = DeprecatedCheckoutViewController.configuredWith(
      initialRequest: initialRequest,
      project: project,
      reward: reward
    )
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .backProject)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func goToTrustAndSafety() {
    let vc = HelpWebViewController.configuredWith(helpType: .trust)
    let nav = UINavigationController(rootViewController: vc)
    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func goToPaymentAuthorization(request: PKPaymentRequest) {
    guard let vc = PKPaymentAuthorizationViewController(paymentRequest: request) else { return }
    vc.delegate = self
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goToShippingPicker(
    project: Project,
    shippingRules: [ShippingRule],
    selectedShippingRule: ShippingRule
  ) {
    let vc = DeprecatedRewardShippingPickerViewController.configuredWith(
      project: project,
      shippingRules: shippingRules,
      selectedShippingRule: selectedShippingRule,
      delegate: self
    )
    vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goToThanks(project: Project) {
    let thanksVC = ThanksViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(thanksVC, animated: true)
  }

  fileprivate func load(items: [String]) {
    self.itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let allItems = items.isEmpty ? [] : [Strings.rewards_info_includes()] + items

    for (idx, item) in allItems.enumerated() {
      let label = UILabel()
        |> UILabel.lens.font .~ (idx == 0 ? UIFont.ksr_callout().bolded : .ksr_body())
        |> UILabel.lens.textColor .~ (idx == 0 ? .ksr_text_dark_grey_400 : .ksr_soft_black)
        |> UILabel.lens.text .~ item
        |> UILabel.lens.numberOfLines .~ 0

      let separator = UIView()
        |> separatorStyle
      separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

      self.itemsStackView.addArrangedSubview(label)
      self.itemsStackView.addArrangedSubview(separator)
    }
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.viewModel.inputs.descriptionLabelIsTruncated(self.descriptionLabel.isTruncated())
  }

  @objc fileprivate func shippingButtonTapped() {
    self.viewModel.inputs.shippingButtonTapped()
  }

  @objc fileprivate func continueWithPaymentButtonTapped() {
    self.viewModel.inputs.continueToPaymentsButtonTapped()
  }

  @objc fileprivate func differentPaymentMethodTapped() {
    self.viewModel.inputs.differentPaymentMethodButtonTapped()
  }

  @objc fileprivate func applePayButtonTapped() {
    self.viewModel.inputs.applePayButtonTapped()
  }

  @objc fileprivate func expandRewardDescriptionTapped() {
    self.viewModel.inputs.expandDescriptionTapped()
  }

  @IBAction internal func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc fileprivate func pledgedTextFieldChanged() {
    self.viewModel.inputs.pledgeTextFieldChanged(self.pledgeTextField.text ?? "")
  }

  @objc fileprivate func pledgedTextFieldDoneEditing() {
    self.viewModel.inputs.pledgeTextFieldDidEndEditing()
    self.pledgeTextField.resignFirstResponder()
  }

  @objc fileprivate func updatePledgeButtonTapped() {
    self.viewModel.inputs.updatePledgeButtonTapped()
  }

  @objc fileprivate func changePaymentMethodButtonTapped() {
    self.viewModel.inputs.changePaymentMethodButtonTapped()
  }

  @objc fileprivate func cancelPledgeButtonTapped() {
    self.viewModel.inputs.cancelPledgeButtonTapped()
  }
}

extension DeprecatedRewardPledgeViewController: UITextViewDelegate {
  func textView(
    _: UITextView, shouldInteractWith _: NSTextAttachment,
    in _: NSRange, interaction _: UITextItemInteraction
  ) -> Bool {
    return false
  }

  func textView(
    _: UITextView, shouldInteractWith _: URL, in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    self.viewModel.inputs.disclaimerButtonTapped()
    return false
  }
}

private let disclaimerTextViewStyle: TextViewStyle = { (textView: UITextView) -> UITextView in
  _ = textView
    |> tappableLinksViewStyle
    |> \.attributedText .~ attributedDisclaimerText()
    |> \.accessibilityTraits .~ [.staticText]

  return textView
}

private func attributedDisclaimerText() -> NSAttributedString? {
  // swiftlint:disable line_length
  let string = localizedString(
    key: "Kickstarter_is_not_a_store_Its_a_way_to_bring_creative_projects_to_life_Learn_more_about_accountability",
    defaultValue: "Kickstarter is not a store. It's a way to bring creative projects to life.</br><a href=\"%{trust_link}\">Learn more about accountability</a>",
    substitutions: [
      "trust_link": HelpType.trust.url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl)?.absoluteString
    ]
    .compactMapValues { $0.coalesceWith("") }
  )
  // swiftlint:enable line_length

  return checkoutAttributedLink(with: string)
}

extension DeprecatedRewardPledgeViewController: PKPaymentAuthorizationViewControllerDelegate {
  internal func paymentAuthorizationViewControllerWillAuthorizePayment(
    _: PKPaymentAuthorizationViewController
  ) {
    self.viewModel.inputs.paymentAuthorizationWillAuthorizePayment()
  }

  internal func paymentAuthorizationViewController(
    _: PKPaymentAuthorizationViewController,
    didAuthorizePayment payment: PKPayment,
    completion: @escaping (PKPaymentAuthorizationStatus) -> Void
  ) {
    self.viewModel.inputs.paymentAuthorization(didAuthorizePayment: .init(payment: payment))

    STPAPIClient.shared().createToken(with: payment) { [weak self] token, error in
      let status = self?.viewModel.inputs.stripeCreatedToken(stripeToken: token?.tokenId, error: error)
      if let status = status {
        completion(status)
      } else {
        completion(.failure)
      }
    }
  }

  internal func paymentAuthorizationViewControllerDidFinish(
    _ controller: PKPaymentAuthorizationViewController
  ) {
    controller.dismiss(animated: true) {
      self.viewModel.inputs.paymentAuthorizationDidFinish()
    }
  }
}

extension DeprecatedRewardPledgeViewController: DeprecatedRewardShippingPickerViewControllerDelegate {
  internal func rewardShippingPickerViewController(
    _ controller: DeprecatedRewardShippingPickerViewController,
    choseShippingRule: ShippingRule
  ) {
    controller.dismiss(animated: true) {
      self.viewModel.inputs.change(shippingRule: choseShippingRule)
    }

    self.navigationController?.view.tintAdjustmentMode = .normal
  }

  internal func rewardShippingPickerViewControllerCancelled(
    _ controller: DeprecatedRewardShippingPickerViewController
  ) {
    controller.dismiss(animated: true, completion: nil)

    self.navigationController?.view.tintAdjustmentMode = .normal
  }

  func rewardShippingPickerViewControllerWillPresent(
    _: DeprecatedRewardShippingPickerViewController
  ) {
    self.navigationController?.view.tintAdjustmentMode = .dimmed
  }
}
