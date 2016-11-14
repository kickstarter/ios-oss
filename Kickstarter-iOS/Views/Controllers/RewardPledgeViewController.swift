// swiftlint:disable file_length
import KsApi
import Library
import Prelude
import Stripe
import UIKit

// swiftlint:disable type_body_length
internal final class RewardPledgeViewController: UIViewController {
  internal let viewModel: RewardPledgeViewModelType = RewardPledgeViewModel()

  @IBOutlet private weak var applePayButton: UIButton!
  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var cancelPledgeButton: UIButton!
  @IBOutlet private weak var cardInnerView: UIView!
  @IBOutlet private weak var cardPanelView: UIView!
  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var changePaymentMethodButton: UIButton!
  @IBOutlet private weak var checkmarkBadgeView: UIView!
  @IBOutlet private weak var checkmarkImageView: UIImageView!
  @IBOutlet private weak var continueToPaymentButton: UIButton!
  @IBOutlet private weak var conversionLabel: UILabel!
  @IBOutlet private weak var countryLabel: UILabel!
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var disclaimerButton: UIButton!
  @IBOutlet private weak var disclaimerContainerView: UIView!
  @IBOutlet private weak var disclaimerPrimaryLabel: UILabel!
  @IBOutlet private weak var disclaimerSecondaryLabel: UILabel!
  @IBOutlet private weak var disclaimerStackView: UIStackView!
  @IBOutlet private weak var disclaimerTertiaryLabel: UILabel!
  @IBOutlet private weak var differentPaymentMethodButton: UIButton!
  @IBOutlet private weak var estimatedDeliveryDateLabel: UILabel!
  @IBOutlet private weak var estimatedFulfillmentStackView: UIStackView!
  @IBOutlet private weak var estimatedToFulfillLabel: UILabel!
  @IBOutlet private weak var fulfillmentAndShippingFooterStackView: UIStackView!
  @IBOutlet private weak var itemsStackView: UIStackView!
  @IBOutlet private weak var middleStackView: UIStackView!
  @IBOutlet private weak var minimumAndConversionStackView: UIStackView!
  @IBOutlet private weak var minimumPledgeLabel: UILabel!
  @IBOutlet private weak var orLabel: UILabel!
  @IBOutlet private weak var pledgeButtonsStackView: UIStackView!
  @IBOutlet private weak var pledgeContainerView: UIView!
  @IBOutlet private weak var pledgeCurrencyLabel: UILabel!
  @IBOutlet private weak var pledgeInputTitleLabel: UILabel!
  @IBOutlet private weak var pledgeInputStackView: UIStackView!
  @IBOutlet private weak var pledgeStackView: UIStackView!
  @IBOutlet private weak var pledgeTextField: UITextField!
  @IBOutlet private weak var readMoreContainerView: UIView!
  @IBOutlet private weak var readMoreGradientView: GradientView!
  @IBOutlet private weak var readMoreLabel: UILabel!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private var separatorViews: [UIView]!
  @IBOutlet private weak var shippingAmountLabel: UILabel!
  @IBOutlet private weak var shippingContainerView: UIView!
  @IBOutlet private weak var shippingDestinationButton: UIButton!
  @IBOutlet private weak var shippingInputStackView: UIStackView!
  @IBOutlet private weak var shippingInputTitleLabel: UILabel!
  @IBOutlet private weak var shippingLocationsLabel: UILabel!
  @IBOutlet private weak var shippingMenuStackView: UIStackView!
  @IBOutlet private weak var shippingStackView: UIStackView!
  @IBOutlet private weak var shipsToLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var topStackView: UIStackView!
  @IBOutlet private weak var updatePledgeButton: UIButton!

  internal static func configuredWith(
    project project: Project,
            reward: Reward,
            applePayCapable: Bool = PKPaymentAuthorizationViewController.applePayCapable())
    -> RewardPledgeViewController {

      let vc = Storyboard.RewardPledge.instantiate(RewardPledgeViewController)
      vc.viewModel.inputs.configureWith(project: project, reward: reward, applePayCapable: applePayCapable)
      return vc
  }

  private var statusBarHidden = true
  override func prefersStatusBarHidden() -> Bool {
    return self.statusBarHidden
  }

  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return .Slide
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.statusBarHidden = false
    UIView.animateWithDuration(0.3) { self.setNeedsStatusBarAppearanceUpdate() }
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.applePayButton.addTarget(
      self, action: #selector(applePayButtonTapped), forControlEvents: .TouchUpInside
    )
    self.cancelPledgeButton.addTarget(
      self, action: #selector(cancelPledgeButtonTapped), forControlEvents: .TouchUpInside
    )
    self.changePaymentMethodButton.addTarget(
      self, action: #selector(changePaymentMethodButtonTapped), forControlEvents: .TouchUpInside
    )
    self.continueToPaymentButton.addTarget(
      self, action: #selector(continueWithPaymentButtonTapped), forControlEvents: .TouchUpInside
    )
    self.descriptionLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(expandRewardDescriptionTapped))
    )
    self.differentPaymentMethodButton.addTarget(
      self, action: #selector(differentPaymentMethodTapped), forControlEvents: .TouchUpInside
    )
    self.disclaimerButton.addTarget(
      self, action: #selector(disclaimerButtonTapped), forControlEvents: .TouchUpInside
    )
    self.pledgeTextField.addTarget(
      self, action: #selector(pledgedTextFieldChanged), forControlEvents: .EditingChanged
    )
    self.pledgeTextField.addTarget(
      self,
      action: #selector(pledgedTextFieldDoneEditing),
      forControlEvents: [.EditingDidEndOnExit, .EditingDidEnd]
    )
    self.readMoreContainerView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(expandRewardDescriptionTapped))
    )
    self.shippingDestinationButton.addTarget(
      self, action: #selector(shippingButtonTapped), forControlEvents: .TouchUpInside
    )
    self.titleLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(expandRewardDescriptionTapped))
    )
    self.updatePledgeButton.addTarget(
      self, action: #selector(updatePledgeButtonTapped), forControlEvents: .TouchUpInside
    )

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseControllerStyle()

    self.applePayButton
      |> roundedStyle(cornerRadius: 4)
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.gridHalf(3))
      |> UIButton.lens.backgroundColor .~ .blackColor()
      |> UIButton.lens.image(forState: .Normal) %~ { _ in
        image(named: "apple-pay-button-content", tintColor: .whiteColor())
      }
      |> UIButton.lens.accessibilityLabel .~ "Apple Pay"

    self.cancelPledgeButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Cancel_your_pledge() }

    self.cardInnerView
      |> cardStyle(cornerRadius: 4)
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_green_700.CGColor
      |> UIView.lens.backgroundColor .~ .ksr_grey_100

    self.cardPanelView
      |> UIView.lens.backgroundColor .~ .ksr_navy_200

    self.cardView
      |> UIView.lens.layer.shadowOpacity .~ 1
      |> UIView.lens.layer.shadowRadius .~ 4
      |> UIView.lens.layer.shouldRasterize .~ true
      |> UIView.lens.layer.shadowOffset .~ CGSize(width: 0, height: 2)
      |> UIView.lens.layer.shadowColor .~ UIColor.ksr_dropShadow.CGColor
      |> UIView.lens.backgroundColor .~ .clearColor()

    self.changePaymentMethodButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Change_payment_method() }

    self.checkmarkBadgeView
      |> UIView.lens.layer.cornerRadius %~~ { _, badge in badge.frame.width / 2 }
      |> UIView.lens.layer.masksToBounds .~ true
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_green_700.CGColor
      |> UIView.lens.layer.borderWidth .~ 1
      |> UIView.lens.backgroundColor .~ UIColor.ksr_green_500

    self.checkmarkImageView
      |> UIImageView.lens.contentMode .~ .Center
      |> UIImageView.lens.image .~ image(named: "checkmark-icon", tintColor: .whiteColor())

    self.continueToPaymentButton
      |> greenButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Continue_to_payment() }

    self.updatePledgeButton
      |> greenButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Update_pledge() }

    self.conversionLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1().italicized
      |> UILabel.lens.textColor .~ UIColor.ksr_text_green_700

    self.countryLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700

    self.descriptionLabel
      |> UILabel.lens.contentMode .~ .TopLeft
      |> UILabel.lens.font .~ UIFont.ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_500
      |> UILabel.lens.numberOfLines .~ 3
      |> UILabel.lens.lineBreakMode .~ .ByTruncatingTail
      |> UILabel.lens.userInteractionEnabled .~ true

    self.differentPaymentMethodButton
      |> baseButtonStyle
      |> roundedStyle(cornerRadius: 4)
      |> UIButton.lens.layer.borderWidth .~ 1
      |> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_500.CGColor
      |> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_green_700
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Other_payment_methods() }

    self.disclaimerButton
      |> UIButton.lens.accessibilityLabel %~ { _ in
        Strings.Kickstarter_is_not_a_store()
          + " " + Strings.Its_a_way_to_bring_creative_projects_to_life()
          + " " + Strings.Learn_more_about_accountability()
    }

    self.disclaimerContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(4))

    self.disclaimerPrimaryLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1(size: 12).bolded
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_500
      |> UILabel.lens.textAlignment .~ .Center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.text %~ { _ in Strings.Kickstarter_is_not_a_store() }

    self.disclaimerSecondaryLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_500
      |> UILabel.lens.textAlignment .~ .Center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.text %~ { _ in Strings.Its_a_way_to_bring_creative_projects_to_life() }

    self.disclaimerTertiaryLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700
      |> UILabel.lens.textAlignment .~ .Center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.attributedText %~ { _ in
        NSAttributedString(
          string: Strings.Learn_more_about_accountability(),
          attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        )
    }

    self.estimatedToFulfillLabel
      |> UILabel.lens.text %~ { _ in Strings.Estimated_to_fulfill() }
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    self.estimatedDeliveryDateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.estimatedFulfillmentStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    self.fulfillmentAndShippingFooterStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    self.itemsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.middleStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(4))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.minimumAndConversionStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    self.minimumPledgeLabel
      |> UILabel.lens.font .~ .ksr_title2()
      |> UILabel.lens.textColor .~ UIColor.ksr_text_green_700

    self.orLabel
      |> UILabel.lens.font .~ .ksr_footnote()
      |> UILabel.lens.textColor .~ .ksr_navy_700

    self.readMoreContainerView
      |> UIView.lens.backgroundColor .~ .clearColor()
      |> UIView.lens.userInteractionEnabled .~ true

    self.readMoreGradientView.backgroundColor = .clearColor()
    self.readMoreGradientView.startPoint = .zero
    self.readMoreGradientView.endPoint = CGPoint(x: 1, y: 0)
    self.readMoreGradientView.setGradient(
      [(UIColor.ksr_grey_100.colorWithAlphaComponent(0.0), 0.0),
        (UIColor.ksr_grey_100.colorWithAlphaComponent(1.0), 1.0)]
    )

    self.readMoreLabel
      |> UILabel.lens.backgroundColor .~ .ksr_grey_100
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.text %~ { _ in Strings.ellipsis_more() }

    self.pledgeButtonsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.pledgeContainerView
      |> UIView.lens.layoutMargins .~ .init(top: Styles.grid(2),
                                            left: Styles.grid(2),
                                            bottom: Styles.grid(2),
                                            right: Styles.grid(4))
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_grey_400.CGColor
      |> UIView.lens.layer.borderWidth .~ 1

    self.pledgeCurrencyLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_green_700

    self.pledgeInputStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.pledgeInputTitleLabel
      |> UILabel.lens.font .~ .ksr_caption1()
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_600
      |> UILabel.lens.text %~ { _ in Strings.Your_pledge_amount() }

    self.pledgeStackView
      |> UIStackView.lens.alignment .~ .FirstBaseline
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    self.pledgeTextField
      |> UITextField.lens.borderStyle .~ .None
      |> UITextField.lens.textColor .~ UIColor.ksr_text_green_700
      |> UITextField.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UITextField.lens.keyboardType .~ .NumberPad

    self.rootStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(4) + Styles.grid(2),
                                                 leftRight: Styles.grid(2) + 1)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(4)

    self.scrollView
      |> UIScrollView.lens.layoutMargins .~ .init(all: Styles.grid(2))
      |> UIScrollView.lens.delaysContentTouches .~ false
      |> UIScrollView.lens.keyboardDismissMode .~ .Interactive

    self.separatorViews
      ||> separatorStyle

    self.shipsToLabel
      |> UILabel.lens.text %~ { _ in Strings.Ships_to() }
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    self.shippingAmountLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.contentCompressionResistancePriorityForAxis(.Horizontal) .~ UILayoutPriorityRequired

    self.shippingInputStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.shippingInputTitleLabel
      |> UILabel.lens.font .~ .ksr_caption1()
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_600
      |> UILabel.lens.text %~ { _ in Strings.Your_shipping_destination() }

    self.shippingLocationsLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.shippingMenuStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.userInteractionEnabled .~ false

    self.shippingContainerView
      |> UIView.lens.layoutMargins .~
        .init(top: Styles.grid(2), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(4))
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.layer.borderColor .~ UIColor.ksr_grey_400.CGColor
      |> UIView.lens.layer.borderWidth .~ 1

    self.shippingDestinationButton
      |> UIButton.lens.backgroundColor(forState: .Highlighted) .~ UIColor.ksr_navy_200
      |> UIButton.lens.isAccessibilityElement .~ true
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_shipping_options() }

    self.shippingStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)
      |> UIStackView.lens.alignment .~ .FirstBaseline

    self.titleLabel
      |> UILabel.lens.font .~ UIFont.ksr_title3(size: 17)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_900
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.userInteractionEnabled .~ true

    self.topStackView
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
      .observeNext { [weak self] in self?.goToPaymentAuthorization(request: $0) }

    self.viewModel.outputs.setStripePublishableKey
      .observeForUI()
      .observeNext { STPPaymentConfiguration.sharedConfiguration().publishableKey = $0 }

    self.viewModel.outputs.setStripeAppleMerchantIdentifier
      .observeForUI()
      .observeNext { STPPaymentConfiguration.sharedConfiguration().appleMerchantIdentifier = $0 }

    self.viewModel.outputs.goToShippingPicker
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.goToShippingPicker(project: $0, shippingRules: $1, selectedShippingRule: $2)
    }

    self.viewModel.outputs.items
      .observeForUI()
      .observeNext { [weak self] in self?.load(items: $0) }

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeNext { [weak self] in self?.dismissViewControllerAnimated(true, completion: nil) }

    self.viewModel.outputs.expandRewardDescription
      .observeForUI()
      .observeNext { [weak self] in
        self?.descriptionLabel.numberOfLines = 0
        self?.view.setNeedsLayout()
        UIView.animateWithDuration(0.2) {
          self?.view.layoutIfNeeded()
        }
    }

    self.viewModel.outputs.itemsContainerHidden
      .observeForUI()
      .observeNext { [weak self] hidden in
        UIView.animateWithDuration(0.2) {
          self?.itemsStackView.hidden = hidden
        }
    }

    self.viewModel.outputs.goToCheckout
      .observeForControllerAction()
      .observeNext { [weak self] initialRequest, project, reward in
        self?.goToCheckout(initialRequest: initialRequest, project: project, reward: reward)
    }

    self.viewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToLoginTout() }

    self.viewModel.outputs.goToThanks
      .observeForControllerAction()
      .observeNext { [weak self] project in self?.goToThanks(project: project) }

    self.viewModel.outputs.showAlert
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.presentViewController(
          UIAlertController.alertController(forError: .genericError(message: $0)),
          animated: true,
          completion: nil
        )
    }

    self.viewModel.outputs.goToTrustAndSafety
      .observeForUI()
      .observeNext { [weak self] in self?.goToTrustAndSafety() }

    Keyboard.change.observeForUI()
      .observeNext { [weak self] in self?.animateTextViewConstraint($0) }
  }
  // swiftlint:enable function_body_length

  private func goToCheckout(initialRequest initialRequest: NSURLRequest,
                                           project: Project,
                                           reward: Reward) {

    let vc = CheckoutViewController.configuredWith(initialRequest: initialRequest,
                                                   project: project,
                                                   reward: reward)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .backProject)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .FormSheet

    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func goToTrustAndSafety() {
    let vc = HelpWebViewController.configuredWith(helpType: .trust)
    let nav = UINavigationController(rootViewController: vc)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func goToPaymentAuthorization(request request: PKPaymentRequest) {
    let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
    vc.delegate = self
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func goToShippingPicker(project project: Project,
                                          shippingRules: [ShippingRule],
                                          selectedShippingRule: ShippingRule) {
    let vc = RewardShippingPickerViewController.configuredWith(project: project,
                                                               shippingRules: shippingRules,
                                                               selectedShippingRule: selectedShippingRule,
                                                               delegate: self)
    vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func goToThanks(project project: Project) {
    let thanksVC = ThanksViewController.configuredWith(project: project)
    let stack = self.navigationController?.viewControllers
    guard let root = stack?.first else {
      fatalError("Unable to find root view controller!")
    }
    self.navigationController?.setViewControllers([root, thanksVC], animated: true)
  }

  private func load(items items: [String]) {
    self.itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let allItems = items.isEmpty ? [] : [Strings.rewards_info_includes()] + items

    for (idx, item) in allItems.enumerate() {
      let label = UILabel()
        |> UILabel.lens.font .~ (idx == 0 ? .ksr_headline(size: 13) : .ksr_body(size: 14))
        |> UILabel.lens.textColor .~ (idx == 0 ? .ksr_text_navy_700 : .ksr_text_navy_600)
        |> UILabel.lens.text .~ item
        |> UILabel.lens.numberOfLines .~ 0

      let separator = UIView()
        |> separatorStyle
      separator.heightAnchor.constraintEqualToConstant(1).active = true

      self.itemsStackView.addArrangedSubview(label)
      self.itemsStackView.addArrangedSubview(separator)
    }
  }

  @objc private func shippingButtonTapped() {
    self.viewModel.inputs.shippingButtonTapped()
  }

  @objc private func disclaimerButtonTapped() {
    self.viewModel.inputs.disclaimerButtonTapped()
  }

  @objc private func continueWithPaymentButtonTapped() {
    self.viewModel.inputs.continueToPaymentsButtonTapped()
  }

  @objc private func differentPaymentMethodTapped() {
    self.viewModel.inputs.differentPaymentMethodButtonTapped()
  }

  @objc private func applePayButtonTapped() {
    self.viewModel.inputs.applePayButtonTapped()
  }

  @objc private func expandRewardDescriptionTapped() {
    self.viewModel.inputs.expandDescriptionTapped()
  }

  @IBAction private func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func pledgedTextFieldChanged() {
    self.viewModel.inputs.pledgeTextFieldChanged(self.pledgeTextField.text ?? "")
  }

  @objc private func pledgedTextFieldDoneEditing() {
    self.viewModel.inputs.pledgeTextFieldDidEndEditing()
    self.pledgeTextField.resignFirstResponder()
  }

  @objc private func updatePledgeButtonTapped() {
    self.viewModel.inputs.updatePledgeButtonTapped()
  }

  @objc private func changePaymentMethodButtonTapped() {
    self.viewModel.inputs.changePaymentMethodButtonTapped()
  }

  @objc private func cancelPledgeButtonTapped() {
    self.viewModel.inputs.cancelPledgeButtonTapped()
  }

  private func animateTextViewConstraint(change: Keyboard.Change) {
    guard self.view.window != nil else { return }

    UIView.animateWithDuration(change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.height - change.frame.minY
      self.scrollView.contentOffset.y += self.bottomConstraint.constant
    }, completion: nil)
  }
}
// swiftlint:enable type_body_length

extension RewardPledgeViewController: PKPaymentAuthorizationViewControllerDelegate {

  internal func paymentAuthorizationViewControllerWillAuthorizePayment(
    controller: PKPaymentAuthorizationViewController) {
    self.viewModel.inputs.paymentAuthorizationWillAuthorizePayment()
  }

  internal func paymentAuthorizationViewController(
    controller: PKPaymentAuthorizationViewController,
    didAuthorizePayment payment: PKPayment,
    completion: (PKPaymentAuthorizationStatus) -> Void) {

    self.viewModel.inputs.paymentAuthorization(didAuthorizePayment: .init(payment: payment))

    STPAPIClient.sharedClient().createTokenWithPayment(payment) { [weak self] token, error in
      if let status = self?.viewModel.inputs.stripeCreatedToken(stripeToken: token?.tokenId, error: error) {
        completion(status)
      } else {
        completion(.Failure)
      }
    }
  }

  internal func paymentAuthorizationViewControllerDidFinish(
    controller: PKPaymentAuthorizationViewController) {

    controller.dismissViewControllerAnimated(true) {
      self.viewModel.inputs.paymentAuthorizationDidFinish()
    }
  }
}

extension RewardPledgeViewController: RewardShippingPickerViewControllerDelegate {
  internal func rewardShippingPickerViewControllerCancelled(controller: RewardShippingPickerViewController) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func rewardShippingPickerViewController(controller: RewardShippingPickerViewController,
                                                   choseShippingRule: ShippingRule) {

    controller.dismissViewControllerAnimated(true) {
      self.viewModel.inputs.change(shippingRule: choseShippingRule)
    }
  }
}
