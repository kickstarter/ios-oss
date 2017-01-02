// swiftlint:disable file_length
import KsApi
import Library
import Prelude
import Stripe
import UIKit

// swiftlint:disable type_body_length
internal final class RewardPledgeViewController: UIViewController {
  internal let viewModel: RewardPledgeViewModelType = RewardPledgeViewModel()

  @IBOutlet fileprivate weak var applePayButton: UIButton!
  @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var cancelPledgeButton: UIButton!
  @IBOutlet fileprivate weak var cardInnerView: UIView!
  @IBOutlet fileprivate weak var cardPanelView: UIView!
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var changePaymentMethodButton: UIButton!
  @IBOutlet fileprivate weak var checkmarkBadgeView: UIView!
  @IBOutlet fileprivate weak var checkmarkImageView: UIImageView!
  @IBOutlet fileprivate weak var continueToPaymentButton: UIButton!
  @IBOutlet fileprivate weak var conversionLabel: UILabel!
  @IBOutlet fileprivate weak var countryLabel: UILabel!
  @IBOutlet fileprivate weak var descriptionLabel: UILabel!
  @IBOutlet fileprivate weak var disclaimerButton: UIButton!
  @IBOutlet fileprivate weak var disclaimerContainerView: UIView!
  @IBOutlet fileprivate weak var disclaimerPrimaryLabel: UILabel!
  @IBOutlet fileprivate weak var disclaimerSecondaryLabel: UILabel!
  @IBOutlet fileprivate weak var disclaimerStackView: UIStackView!
  @IBOutlet fileprivate weak var disclaimerTertiaryLabel: UILabel!
  @IBOutlet fileprivate weak var differentPaymentMethodButton: UIButton!
  @IBOutlet fileprivate weak var estimatedDeliveryDateLabel: UILabel!
  @IBOutlet fileprivate weak var estimatedFulfillmentStackView: UIStackView!
  @IBOutlet fileprivate weak var estimatedToFulfillLabel: UILabel!
  @IBOutlet fileprivate weak var fulfillmentAndShippingFooterStackView: UIStackView!
  @IBOutlet fileprivate weak var itemsStackView: UIStackView!
  @IBOutlet fileprivate weak var loadingIndicatorView: UIActivityIndicatorView!
  @IBOutlet fileprivate weak var loadingOverlayView: UIView!
  @IBOutlet fileprivate weak var middleStackView: UIStackView!
  @IBOutlet fileprivate weak var minimumAndConversionStackView: UIStackView!
  @IBOutlet fileprivate weak var minimumPledgeLabel: UILabel!
  @IBOutlet fileprivate weak var orLabel: UILabel!
  @IBOutlet fileprivate weak var pledgeButtonsStackView: UIStackView!
  @IBOutlet fileprivate weak var pledgeContainerView: UIView!
  @IBOutlet fileprivate weak var pledgeCurrencyLabel: UILabel!
  @IBOutlet fileprivate weak var pledgeInputTitleLabel: UILabel!
  @IBOutlet fileprivate weak var pledgeInputStackView: UIStackView!
  @IBOutlet fileprivate weak var pledgeStackView: UIStackView!
  @IBOutlet fileprivate weak var pledgeTextField: UITextField!
  @IBOutlet fileprivate weak var readMoreContainerView: UIView!
  @IBOutlet fileprivate weak var readMoreGradientView: GradientView!
  @IBOutlet fileprivate weak var readMoreLabel: UILabel!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate weak var shippingAmountLabel: UILabel!
  @IBOutlet fileprivate weak var shippingContainerView: UIView!
  @IBOutlet fileprivate weak var shippingDestinationButton: UIButton!
  @IBOutlet fileprivate weak var shippingInputStackView: UIStackView!
  @IBOutlet fileprivate weak var shippingInputTitleLabel: UILabel!
  @IBOutlet fileprivate weak var shippingLocationsLabel: UILabel!
  @IBOutlet fileprivate weak var shippingMenuStackView: UIStackView!
  @IBOutlet fileprivate weak var shippingStackView: UIStackView!
  @IBOutlet fileprivate weak var shipsToLabel: UILabel!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var topStackView: UIStackView!
  @IBOutlet fileprivate weak var updatePledgeButton: UIButton!

  internal static func configuredWith(
    project: Project,
            reward: Reward,
            applePayCapable: Bool = PKPaymentAuthorizationViewController.applePayCapable())
    -> RewardPledgeViewController {

      let vc = Storyboard.RewardPledge.instantiate(RewardPledgeViewController.self)
      vc.viewModel.inputs.configureWith(project: project, reward: reward, applePayCapable: applePayCapable)
      return vc
  }

  fileprivate var statusBarHidden = true
  override var prefersStatusBarHidden: Bool {
    return self.statusBarHidden
  }

  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .slide
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.statusBarHidden = false
    UIView.animate(withDuration: 0.3, animations: { self.setNeedsStatusBarAppearanceUpdate() })
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.applePayButton.addTarget(
      self, action: #selector(applePayButtonTapped), for: .touchUpInside
    )
    self.cancelPledgeButton.addTarget(
      self, action: #selector(cancelPledgeButtonTapped), for: .touchUpInside
    )
    self.changePaymentMethodButton.addTarget(
      self, action: #selector(changePaymentMethodButtonTapped), for: .touchUpInside
    )
    self.continueToPaymentButton.addTarget(
      self, action: #selector(continueWithPaymentButtonTapped), for: .touchUpInside
    )
    self.descriptionLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(expandRewardDescriptionTapped))
    )
    self.differentPaymentMethodButton.addTarget(
      self, action: #selector(differentPaymentMethodTapped), for: .touchUpInside
    )
    self.disclaimerButton.addTarget(
      self, action: #selector(disclaimerButtonTapped), for: .touchUpInside
    )
    self.pledgeTextField.addTarget(
      self, action: #selector(pledgedTextFieldChanged), for: .editingChanged
    )
    self.pledgeTextField.addTarget(
      self,
      action: #selector(pledgedTextFieldDoneEditing),
      for: [.editingDidEndOnExit, .editingDidEnd]
    )
    self.readMoreContainerView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(expandRewardDescriptionTapped))
    )
    self.shippingDestinationButton.addTarget(
      self, action: #selector(shippingButtonTapped), for: .touchUpInside
    )
    self.titleLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(expandRewardDescriptionTapped))
    )
    self.updatePledgeButton.addTarget(
      self, action: #selector(updatePledgeButtonTapped), for: .touchUpInside
    )

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()

    _ = self.applePayButton
      |> roundedStyle(cornerRadius: 4)
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.gridHalf(3))
      |> UIButton.lens.backgroundColor .~ .black
      |> UIButton.lens.image(forState: .normal) %~ { _ in
        image(named: "apple-pay-button-content", tintColor: .white)
      }
      |> UIButton.lens.accessibilityLabel .~ "Apple Pay"

    _ = self.cancelPledgeButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Cancel_your_pledge() }

    _ = self.cardInnerView
      |> cardStyle(cornerRadius: 4)
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_green_700.cgColor
      |> UIView.lens.backgroundColor .~ .ksr_grey_100

    _ = self.cardPanelView
      |> UIView.lens.backgroundColor .~ .ksr_navy_200

    _ = self.cardView
      |> UIView.lens.layer.shadowOpacity .~ 1
      |> UIView.lens.layer.shadowRadius .~ 4
      |> UIView.lens.layer.shouldRasterize .~ true
      |> UIView.lens.layer.shadowOffset .~ CGSize(width: 0, height: 2)
      |> UIView.lens.layer.shadowColor .~ UIColor.ksr_dropShadow.cgColor
      |> UIView.lens.backgroundColor .~ .clear

    _ = self.changePaymentMethodButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Change_payment_method() }

    _ = self.checkmarkBadgeView
      |> UIView.lens.layer.cornerRadius %~~ { _, badge in badge.frame.width / 2 }
      |> UIView.lens.layer.masksToBounds .~ true
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_green_700.cgColor
      |> UIView.lens.layer.borderWidth .~ 1
      |> UIView.lens.backgroundColor .~ UIColor.ksr_green_500

    _ = self.checkmarkImageView
      |> UIImageView.lens.contentMode .~ .center
      |> UIImageView.lens.image .~ image(named: "checkmark-icon", tintColor: .white)

    _ = self.continueToPaymentButton
      |> greenButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Continue_to_payment() }

    _ = self.updatePledgeButton
      |> greenButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Update_pledge() }

    _ = self.conversionLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1().italicized
      |> UILabel.lens.textColor .~ UIColor.ksr_text_green_700

    _ = self.countryLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700

    _ = self.descriptionLabel
      |> UILabel.lens.contentMode .~ .topLeft
      |> UILabel.lens.font .~ UIFont.ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_500
      |> UILabel.lens.numberOfLines .~ 3
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail
      |> UILabel.lens.userInteractionEnabled .~ true

    _ = self.differentPaymentMethodButton
      |> baseButtonStyle
      |> roundedStyle(cornerRadius: 4)
      |> UIButton.lens.layer.borderWidth .~ 1
      |> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_500.cgColor
      |> UIButton.lens.titleColor(forState: .normal) .~ .ksr_text_green_700
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Other_payment_methods() }

    _ = self.disclaimerButton
      |> UIButton.lens.accessibilityLabel %~ { _ in
        Strings.Kickstarter_is_not_a_store()
          + " " + Strings.Its_a_way_to_bring_creative_projects_to_life()
          + " " + Strings.Learn_more_about_accountability()
    }

    _ = self.disclaimerContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(4))

    _ = self.disclaimerPrimaryLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1(size: 12).bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_500
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.text %~ { _ in Strings.Kickstarter_is_not_a_store() }

    _ = self.disclaimerSecondaryLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_500
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.text %~ { _ in Strings.Its_a_way_to_bring_creative_projects_to_life() }

    _ = self.disclaimerTertiaryLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.attributedText %~ { _ in
        NSAttributedString(
          string: Strings.Learn_more_about_accountability(),
          attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        )
    }

    _ = self.estimatedToFulfillLabel
      |> UILabel.lens.text %~ { _ in Strings.Estimated_to_fulfill() }
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    _ = self.estimatedDeliveryDateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.estimatedFulfillmentStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.fulfillmentAndShippingFooterStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.itemsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.loadingIndicatorView
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.color .~ .ksr_navy_900

    _ = self.loadingOverlayView
      |> UIView.lens.backgroundColor .~ UIColor(white: 1.0, alpha: 0.99)

    _ = self.middleStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(4))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.minimumAndConversionStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.minimumPledgeLabel
      |> UILabel.lens.font .~ .ksr_title2()
      |> UILabel.lens.textColor .~ UIColor.ksr_text_green_700

    _ = self.orLabel
      |> UILabel.lens.font .~ .ksr_footnote()
      |> UILabel.lens.textColor .~ .ksr_navy_700

    _ = self.readMoreContainerView
      |> UIView.lens.backgroundColor .~ .clear
      |> UIView.lens.userInteractionEnabled .~ true

    _ = self.readMoreGradientView.backgroundColor = .clear
    _ = self.readMoreGradientView.startPoint = .zero
    _ = self.readMoreGradientView.endPoint = CGPoint(x: 1, y: 0)
    _ = self.readMoreGradientView.setGradient(
      [(UIColor.ksr_grey_100.withAlphaComponent(0.0), 0.0),
        (UIColor.ksr_grey_100.withAlphaComponent(1.0), 1.0)]
    )

    _ = self.readMoreLabel
      |> UILabel.lens.backgroundColor .~ .ksr_grey_100
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.text %~ { _ in Strings.ellipsis_more() }

    _ = self.pledgeButtonsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.pledgeContainerView
      |> UIView.lens.layoutMargins .~ .init(top: Styles.grid(2),
                                            left: Styles.grid(2),
                                            bottom: Styles.grid(2),
                                            right: Styles.grid(4))
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_grey_400.cgColor
      |> UIView.lens.layer.borderWidth .~ 1

    _ = self.pledgeCurrencyLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_green_700

    _ = self.pledgeInputStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.pledgeInputTitleLabel
      |> UILabel.lens.font .~ .ksr_caption1()
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_600
      |> UILabel.lens.text %~ { _ in Strings.Your_pledge_amount() }

    _ = self.pledgeStackView
      |> UIStackView.lens.alignment .~ .firstBaseline
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.pledgeTextField
      |> UITextField.lens.borderStyle .~ .none
      |> UITextField.lens.textColor .~ UIColor.ksr_text_green_700
      |> UITextField.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UITextField.lens.keyboardType .~ .numberPad

    _ = self.rootStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(4) + Styles.grid(2),
                                                 leftRight: Styles.grid(2) + 1)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(4)

    _ = self.scrollView
      |> UIScrollView.lens.layoutMargins .~ .init(all: Styles.grid(2))
      |> UIScrollView.lens.delaysContentTouches .~ false
      |> UIScrollView.lens.keyboardDismissMode .~ .interactive

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.shipsToLabel
      |> UILabel.lens.text %~ { _ in Strings.Ships_to() }
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    _ = self.shippingAmountLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ UILayoutPriorityRequired

    _ = self.shippingInputStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.shippingInputTitleLabel
      |> UILabel.lens.font .~ .ksr_caption1()
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_600
      |> UILabel.lens.text %~ { _ in Strings.Your_shipping_destination() }

    _ = self.shippingLocationsLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.shippingMenuStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.userInteractionEnabled .~ false

    _ = self.shippingContainerView
      |> UIView.lens.layoutMargins .~
        .init(top: Styles.grid(2), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(4))
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_grey_400.cgColor
      |> UIView.lens.layer.borderWidth .~ 1

    _ = self.shippingDestinationButton
      |> UIButton.lens.backgroundColor(forState: .highlighted) .~ UIColor.ksr_navy_200
      |> UIButton.lens.isAccessibilityElement .~ true
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_shipping_options() }

    _ = self.shippingStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)
      |> UIStackView.lens.alignment .~ .firstBaseline

    _ = self.titleLabel
      |> UILabel.lens.font .~ UIFont.ksr_title3(size: 17)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_900
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.userInteractionEnabled .~ true

    _ = self.topStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(4))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.navigationItem.leftBarButtonItem?.image = image(named: "close-icon", tintColor: .ksr_navy_600)
    self.navigationItem.leftBarButtonItem?.accessibilityLabel = Strings.general_navigation_buttons_close()
  }
  // swiftlint:enable function_body_length

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.applePayButton.rac.hidden = self.viewModel.outputs.applePayButtonHidden
    self.cancelPledgeButton.rac.hidden = self.viewModel.outputs.cancelPledgeButtonHidden
    self.changePaymentMethodButton.rac.hidden = self.viewModel.outputs.changePaymentMethodButtonHidden
    self.continueToPaymentButton.rac.hidden = self.viewModel.outputs.continueToPaymentsButtonHidden
    self.conversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.conversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.countryLabel.rac.text = self.viewModel.outputs.countryLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.differentPaymentMethodButton.rac.hidden = self.viewModel.outputs.differentPaymentMethodButtonHidden
    self.estimatedDeliveryDateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryDateLabelText
    self.fulfillmentAndShippingFooterStackView.rac.hidden
      = self.viewModel.outputs.fulfillmentAndShippingFooterStackViewHidden
    self.loadingIndicatorView.rac.animating = self.viewModel.outputs.pledgeIsLoading
    self.loadingOverlayView.rac.hidden = self.viewModel.outputs.loadingOverlayIsHidden
    self.minimumPledgeLabel.rac.text = self.viewModel.outputs.minimumLabelText
    self.navigationItem.rac.title = self.viewModel.outputs.navigationTitle
    self.orLabel.rac.hidden = self.viewModel.outputs.orLabelHidden
    self.pledgeCurrencyLabel.rac.text = self.viewModel.outputs.pledgeCurrencyLabelText
    self.pledgeTextField.rac.text = self.viewModel.outputs.pledgeTextFieldText
    self.readMoreContainerView.rac.hidden = self.viewModel.outputs.readMoreContainerViewHidden
    self.shippingAmountLabel.rac.text = self.viewModel.outputs.shippingAmountLabelText
    self.shippingInputStackView.rac.hidden = self.viewModel.outputs.shippingInputStackViewHidden
    self.shippingLocationsLabel.rac.text = self.viewModel.outputs.shippingLocationsLabelText
    self.titleLabel.rac.hidden = self.viewModel.outputs.titleLabelHidden
    self.titleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.updatePledgeButton.rac.hidden = self.viewModel.outputs.updatePledgeButtonHidden

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
      .observeValues { [weak self] project in self?.goToThanks(project: project) }

    self.viewModel.outputs.showAlert
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.present(
          UIAlertController.alertController(forError: .genericError(message: $0)),
          animated: true,
          completion: nil
        )
    }

    self.viewModel.outputs.goToTrustAndSafety
      .observeForUI()
      .observeValues { [weak self] in self?.goToTrustAndSafety() }

    Keyboard.change.observeForUI()
      .observeValues { [weak self] in self?.animateTextViewConstraint($0) }
  }
  // swiftlint:enable function_body_length

  fileprivate func goToCheckout(initialRequest: URLRequest,
                                           project: Project,
                                           reward: Reward) {

    let vc = CheckoutViewController.configuredWith(initialRequest: initialRequest,
                                                   project: project,
                                                   reward: reward)
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
    let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
    vc.delegate = self
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goToShippingPicker(project: Project,
                                          shippingRules: [ShippingRule],
                                          selectedShippingRule: ShippingRule) {
    let vc = RewardShippingPickerViewController.configuredWith(project: project,
                                                               shippingRules: shippingRules,
                                                               selectedShippingRule: selectedShippingRule,
                                                               delegate: self)
    vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goToThanks(project: Project) {
    let thanksVC = ThanksViewController.configuredWith(project: project)
    let stack = self.navigationController?.viewControllers
    guard let root = stack?.first else {
      fatalError("Unable to find root view controller!")
    }
    self.navigationController?.setViewControllers([root, thanksVC], animated: true)
  }

  fileprivate func load(items: [String]) {
    self.itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let allItems = items.isEmpty ? [] : [Strings.rewards_info_includes()] + items

    for (idx, item) in allItems.enumerated() {
      let label = UILabel()
        |> UILabel.lens.font .~ (idx == 0 ? .ksr_headline(size: 13) : .ksr_body(size: 14))
        |> UILabel.lens.textColor .~ (idx == 0 ? .ksr_text_navy_700 : .ksr_text_navy_600)
        |> UILabel.lens.text .~ item
        |> UILabel.lens.numberOfLines .~ 0

      let separator = UIView()
        |> separatorStyle
      separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

      self.itemsStackView.addArrangedSubview(label)
      self.itemsStackView.addArrangedSubview(separator)
    }
  }

  @objc fileprivate func shippingButtonTapped() {
    self.viewModel.inputs.shippingButtonTapped()
  }

  @objc fileprivate func disclaimerButtonTapped() {
    self.viewModel.inputs.disclaimerButtonTapped()
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

  @IBAction fileprivate func closeButtonTapped() {
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

  fileprivate func animateTextViewConstraint(_ change: Keyboard.Change) {
    guard self.view.window != nil else { return }

    UIView.animate(withDuration: change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.height - change.frame.minY
      self.scrollView.contentOffset.y += self.bottomConstraint.constant
    }, completion: nil)
  }
}
// swiftlint:enable type_body_length

extension RewardPledgeViewController: PKPaymentAuthorizationViewControllerDelegate {

  internal func paymentAuthorizationViewControllerWillAuthorizePayment(
    _ controller: PKPaymentAuthorizationViewController) {
    self.viewModel.inputs.paymentAuthorizationWillAuthorizePayment()
  }

  internal func paymentAuthorizationViewController(
    _ controller: PKPaymentAuthorizationViewController,
    didAuthorizePayment payment: PKPayment,
    completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {

    self.viewModel.inputs.paymentAuthorization(didAuthorizePayment: .init(payment: payment))

    STPAPIClient.shared().createToken(with: payment) { [weak self] token, error in
      // FIXME: dont use NSError
//      if let status = self?.viewModel.inputs.stripeCreatedToken(stripeToken: token?.tokenId, error: error) {
//        completion(status)
//      } else {
//        completion(.failure)
//      }
    }
  }

  internal func paymentAuthorizationViewControllerDidFinish(
    _ controller: PKPaymentAuthorizationViewController) {

    controller.dismiss(animated: true) {
      self.viewModel.inputs.paymentAuthorizationDidFinish()
    }
  }
}

extension RewardPledgeViewController: RewardShippingPickerViewControllerDelegate {
  internal func rewardShippingPickerViewControllerCancelled(_ controller: RewardShippingPickerViewController) {
    controller.dismiss(animated: true, completion: nil)
  }

  internal func rewardShippingPickerViewController(_ controller: RewardShippingPickerViewController,
                                                   choseShippingRule: ShippingRule) {

    controller.dismiss(animated: true) {
      self.viewModel.inputs.change(shippingRule: choseShippingRule)
    }
  }
}
