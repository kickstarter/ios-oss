import KsApi
import Library
import Prelude
import Stripe
import UIKit

final class UpdatePledgeViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: - Properties

  private lazy var pledgeAmountViewController = {
    PledgeAmountViewController.instantiate()
      |> \.delegate .~ self
  }()

  internal var messageBannerViewController: MessageBannerViewController?

  private lazy var confirmationLabel: UILabel = {
    UILabel(frame: .zero)
  }()

  private lazy var shippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var summaryViewController = {
    PledgeSummaryViewController.instantiate()
  }()

  private lazy var rootScrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var sessionStartedObserver: Any?
  private let viewModel: UpdatePledgeViewModelType = UpdatePledgeViewModel()

  // MARK: - Lifecycle

  func configureWith(project: Project, reward: Reward, refTag: RefTag?) {
    self.viewModel.inputs.configureWith(project: project, reward: reward, refTag: refTag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    _ = self
      |> \.title %~ { _ in Strings.Update_pledge() }

    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.view.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(UpdatePledgeViewController.dismissKeyboard))
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
    let childViewControllers = [
      self.pledgeAmountViewController,
      self.shippingLocationViewController,
      self.summaryViewController
    ]

    let arrangedSubviews = [
      self.pledgeAmountViewController.view,
      self.shippingLocationViewController.view,
      self.summaryViewController.view,
      self.confirmationLabel
    ]
    .compact()

    arrangedSubviews.forEach { view in
      self.rootStackView.addArrangedSubview(view)
    }

    childViewControllers.forEach { viewController in
      self.addChild(viewController)
      viewController.didMove(toParent: self)
    }
  }

  private func setupConstraints() {
    self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor).isActive = true
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.rootScrollView
      |> rootScrollViewStyle

    _ = self.rootStackView
      |> checkoutRootStackViewStyle

    _ = self.confirmationLabel
      |> \.numberOfLines .~ 0
      |> checkoutBackgroundStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeAmountViewController.configureWith(value: data)
        self?.shippingLocationViewController.configureWith(value: data)
      }

    self.viewModel.outputs.configureSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] project, pledgeTotal in
        self?.summaryViewController.configureWith(value: (project, pledgeTotal))
      }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.rootScrollView.handleKeyboardVisibilityDidChange(change)
      }

    self.shippingLocationViewController.view.rac.hidden
      = self.viewModel.outputs.shippingLocationViewHidden

    self.confirmationLabel.rac.attributedText = self.viewModel.outputs.confirmationLabelAttributedText
  }

  // MARK: - Actions

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

// MARK: - PledgeAmountViewControllerDelegate

extension UpdatePledgeViewController: PledgeAmountViewControllerDelegate {
  func pledgeAmountViewController(
    _: PledgeAmountViewController,
    didUpdateAmount amount: Double
  ) {
    self.viewModel.inputs.pledgeAmountDidUpdate(to: amount)
  }
}

// MARK: - PledgeShippingLocationViewControllerDelegate

extension UpdatePledgeViewController: PledgeShippingLocationViewControllerDelegate {
  func pledgeShippingLocationViewController(
    _: PledgeShippingLocationViewController,
    didSelect shippingRule: ShippingRule
  ) {
    self.viewModel.inputs.shippingRuleSelected(shippingRule)
  }
}

// MARK: - UpdatePledgeViewControllerMessageDisplaying

extension UpdatePledgeViewController: PledgeViewControllerMessageDisplaying {
  func pledgeViewController(_: UIViewController, didErrorWith message: String) {
    self.messageBannerViewController?.showBanner(with: .error, message: message)
  }

  func pledgeViewController(_: UIViewController, didSucceedWith message: String) {
    self.messageBannerViewController?.showBanner(with: .success, message: message)
  }
}

// MARK: - Styles

private let rootScrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> UIScrollView.lens.showsVerticalScrollIndicator .~ false
    |> \.alwaysBounceVertical .~ true
}
