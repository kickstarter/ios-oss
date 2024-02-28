import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Style {
    static let cornerRadius: CGFloat = Styles.grid(2)
    static let modalHeightMultiplier: CGFloat = 0.65
  }

  enum Margin {
    static let topBottom: CGFloat = Styles.grid(3)
    static let leftRight: CGFloat = CheckoutConstants.PledgeView.Inset.leftRight
  }
}

protocol ConfirmDetailsViewControllerDelegate: AnyObject {
  func viewControllerDidUpdatePledge(_ viewController: ConfirmDetailsViewController, message: String)
}

final class ConfirmDetailsViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: - Properties

  public weak var delegate: ConfirmDetailsViewControllerDelegate?

  private lazy var titleLabel = UILabel(frame: .zero)

  private lazy var pledgeAmountViewController = {
    PledgeAmountViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var continueCTAView: ConfirmDetailsContinueCTAView = {
    ConfirmDetailsContinueCTAView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var inputsSectionViews = {
    [
      self.shippingLocationViewController.view,
      self.shippingSummaryView,
      self.localPickupLocationView,
      self.pledgeAmountViewController.view
    ]
  }()

  fileprivate lazy var keyboardDimissingTapGestureRecognizer: UITapGestureRecognizer = {
    UITapGestureRecognizer(
      target: self,
      action: #selector(ConfirmDetailsViewController.dismissKeyboard)
    )
      |> \.cancelsTouchesInView .~ false
  }()

  internal var messageBannerViewController: MessageBannerViewController?

  private lazy var pledgeAmountSummaryViewController: PledgeAmountSummaryViewController = {
    PledgeAmountSummaryViewController.instantiate()
  }()

  private lazy var shippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var localPickupLocationView = {
    PledgeLocalPickupView(frame: .zero)
  }()

  private lazy var shippingSummaryView: PledgeShippingSummaryView = {
    PledgeShippingSummaryView(frame: .zero)
  }()

  private lazy var expandableRewardsViewController = {
    PostCampaignPledgeExpandableRewardsViewController.instantiate()
  }()

  private lazy var rootScrollView: UIScrollView = {
    UIScrollView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootInsetStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var sessionStartedObserver: Any?
  private let viewModel: ConfirmDetailsViewModelType = ConfirmDetailsViewModel()

  // MARK: - Lifecycle

  func configure(with data: PledgeViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem
      .backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    _ = self
      |> \.title .~ Strings.Back_this_project()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.view.addGestureRecognizer(self.keyboardDimissingTapGestureRecognizer)

    self.continueCTAView.continueButton.addTarget(
      self,
      action: #selector(ConfirmDetailsViewController.continueButtonTapped),
      for: .touchUpInside
    )

    self.configureChildViewControllers()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.continueCTAView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    let childViewControllers = [
      self.expandableRewardsViewController,
      self.pledgeAmountSummaryViewController,
      self.pledgeAmountViewController,
      self.shippingLocationViewController
    ]

    let arrangedSubviews = [
      self.rootInsetStackView
    ]

    let arrangedInsetSubviews = [
      [self.titleLabel],
      self.inputsSectionViews,
      [self.pledgeAmountSummaryViewController.view],
      [self.expandableRewardsViewController.view]
    ]
    .flatMap { $0 }
    .compact()

    arrangedSubviews.forEach { view in
      self.rootStackView.addArrangedSubview(view)
    }

    arrangedInsetSubviews.forEach { view in
      self.rootInsetStackView.addArrangedSubview(view)
    }

    childViewControllers.forEach { viewController in
      self.addChild(viewController)
      viewController.didMove(toParent: self)
    }

    self.rootStackView
      .setCustomSpacing(Styles.grid(2), after: self.expandableRewardsViewController.view)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.rootScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.rootScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.rootScrollView.bottomAnchor.constraint(equalTo: self.continueCTAView.topAnchor),
      self.continueCTAView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.continueCTAView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.continueCTAView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.rootScrollView
      |> rootScrollViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.rootInsetStackView
      |> rootInsetStackViewStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.expandableRewardsViewController.view.rac.hidden
      = self.viewModel.outputs.expandableRewardsViewHidden

    self.viewModel.outputs.configureLocalPickupViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.localPickupLocationView.configure(with: data)
      }

    self.viewModel.outputs.configureShippingLocationViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.shippingLocationViewController.configureWith(value: data)
      }

    self.viewModel.outputs.configureShippingSummaryViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.shippingSummaryView.configure(with: data)
      }

    self.viewModel.outputs.configurePledgeAmountViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeAmountViewController.configureWith(value: data)
      }

    self.viewModel.outputs.configurePledgeSummaryHeaderWithData
      .observeForUI()
      .observeValues { [weak self] _ in }

    self.viewModel.outputs.configurePledgeAmountSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeAmountSummaryViewController.configureWith(data)
      }

    self.viewModel.outputs.notifyPledgeAmountViewControllerUnavailableAmountChanged
      .observeForUI()
      .observeValues { [weak self] amount in
        self?.pledgeAmountViewController.unavailableAmountChanged(to: amount)
      }

    self.viewModel.outputs.configureExpandableRewardsViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.expandableRewardsViewController.configure(with: data)
      }

    self.viewModel.outputs.goToLoginSignup
      .observeForControllerAction()
      .observeValues { [weak self] intent, project, reward in
        self?.goToLoginSignup(with: intent, project: project, reward: reward)
      }

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.rootScrollView.handleKeyboardVisibilityDidChange(change)
      }

    self.viewModel.outputs.rootStackViewLayoutMargins
      .observeForUI()
      .observeValues { [weak self] margins in
        self?.rootStackView.layoutMargins = margins
      }

    self.localPickupLocationView.rac.hidden = self.viewModel.outputs.localPickupViewHidden
    self.shippingLocationViewController.view.rac.hidden
      = self.viewModel.outputs.shippingLocationViewHidden
    self.shippingSummaryView.rac.hidden
      = self.viewModel.outputs.shippingSummaryViewHidden
    self.pledgeAmountViewController.view.rac.hidden = self.viewModel.outputs.pledgeAmountViewHidden
    self.pledgeAmountSummaryViewController.view.rac.hidden
      = self.viewModel.outputs.pledgeAmountSummaryViewHidden
  }

  // MARK: - Actions

  @objc func continueButtonTapped() {
//    self.viewModel.inputs.continueButtonTapped()
  }

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }

  // MARK: - Functions

  private func goToLoginSignup(with intent: LoginIntent, project: Project, reward: Reward) {
    let loginSignupViewController = LoginToutViewController.configuredWith(
      loginIntent: intent,
      project: project,
      reward: reward
    )

    let navigationController = UINavigationController(rootViewController: loginSignupViewController)

    self.present(navigationController, animated: true)
  }
}

// MARK: - PledgeAmountViewControllerDelegate

extension ConfirmDetailsViewController: PledgeAmountViewControllerDelegate {
  func pledgeAmountViewController(
    _: PledgeAmountViewController,
    didUpdateWith data: PledgeAmountData
  ) {
    self.viewModel.inputs.pledgeAmountViewControllerDidUpdate(with: data)
  }
}

// MARK: - PledgeShippingLocationViewControllerDelegate

extension ConfirmDetailsViewController: PledgeShippingLocationViewControllerDelegate {
  func pledgeShippingLocationViewController(
    _: PledgeShippingLocationViewController,
    didSelect shippingRule: ShippingRule
  ) {
    self.viewModel.inputs.shippingRuleSelected(shippingRule)
  }

  func pledgeShippingLocationViewControllerLayoutDidUpdate(_: PledgeShippingLocationViewController) {}
  func pledgeShippingLocationViewControllerFailedToLoad(_: PledgeShippingLocationViewController) {}
}

// MARK: - ConfirmDetailsViewControllerMessageDisplaying

extension ConfirmDetailsViewController: PledgeViewControllerMessageDisplaying {
  func pledgeViewController(_: UIViewController, didErrorWith message: String) {
    self.messageBannerViewController?.showBanner(with: .error, message: message)
  }

  func pledgeViewController(_: UIViewController, didSucceedWith message: String) {
    self.messageBannerViewController?.showBanner(with: .success, message: message)
  }
}

// MARK: - Styles

private let titleLabelStyle: LabelStyle = { label in
  label
    // TODO: [MBL-1217] Update string once translations are done
    |> \.text %~ { _ in "Confirm your pledge details." }
    |> \.font .~ UIFont.ksr_title2().bolded
    |> \.numberOfLines .~ 0
}

private let rootScrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> \.showsVerticalScrollIndicator .~ false
    |> \.alwaysBounceVertical .~ true
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.spacing .~ Styles.grid(4)
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let rootInsetStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.spacing .~ Styles.grid(4)
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets(
      topBottom: Layout.Margin.topBottom,
      leftRight: Layout.Margin.leftRight
    )
}
