import KsApi
import Library
import Prelude
import UIKit

final class PledgeViewController: UIViewController {
  // MARK: - Properties

  private lazy var pledgeAmountViewController = {
    PledgeAmountViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var pledgeContinueViewController = {
    PledgeContinueViewController.instantiate()
  }()

  private lazy var pledgeDescriptionViewController = {
    PledgeDescriptionViewController.instantiate()
  }()

  private lazy var pledgeSummaryViewController = {
    PledgeSummaryViewController.instantiate()
  }()

  private lazy var pledgeShippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var pledgePaymentMethodsViewController = {
    PledgePaymentMethodsViewController.instantiate()
  }()

  private lazy var rootScrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var sessionStartedObserver: Any?
  private let viewModel: PledgeViewModelType = PledgeViewModel()

  // MARK: - Lifecycle

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project: project, reward: reward)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Back_this_project() }

    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.configureChildViewControllers()

    self.view.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(PledgeViewController.dismissKeyboard))
    )

    self.setupConstraints()
    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    let childViewControllers = [
      self.pledgeDescriptionViewController,
      self.pledgeAmountViewController,
      self.pledgeShippingLocationViewController,
      self.pledgeSummaryViewController,
      self.pledgeContinueViewController,
      self.pledgePaymentMethodsViewController
    ]

    childViewControllers.forEach { viewController in
      self.addChild(viewController)
      self.rootStackView.addArrangedSubview(viewController.view)
      viewController.didMove(toParent: self)
    }
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.rootScrollView
      |> rootScrollViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeDescriptionViewController.configureWith(value: data.reward)
        self?.pledgeAmountViewController.configureWith(value: data)
        self?.pledgeShippingLocationViewController.configureWith(value: data)
        self?.pledgePaymentMethodsViewController.configureWith(value: [GraphUserCreditCard.template])
      }

    self.viewModel.outputs.configureSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] project, pledgeTotal in
        self?.pledgeSummaryViewController.configureWith(value: (project, pledgeTotal))
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

    self.pledgeShippingLocationViewController.view.rac.hidden
      = self.viewModel.outputs.shippingLocationViewHidden
    self.pledgeContinueViewController.view.rac.hidden = self.viewModel.outputs.continueViewHidden
    self.pledgePaymentMethodsViewController.view.rac.hidden = self.viewModel.outputs.paymentMethodsViewHidden
  }

  // MARK: - Actions

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

extension PledgeViewController: PledgeAmountViewControllerDelegate {
  func pledgeAmountViewController(
    _: PledgeAmountViewController,
    didUpdateAmount amount: Double
  ) {
    self.viewModel.inputs.pledgeAmountDidUpdate(to: amount)
  }
}

extension PledgeViewController: PledgeShippingLocationViewControllerDelegate {
  func pledgeShippingLocationViewController(
    _: PledgeShippingLocationViewController,
    didSelect shippingRule: ShippingRule
  ) {
    self.viewModel.inputs.shippingRuleSelected(shippingRule)
  }
}

// MARK: - Styles

private let rootScrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> UIScrollView.lens.showsVerticalScrollIndicator .~ false
    |> \.alwaysBounceVertical .~ true
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ .init(
      top: Styles.grid(3),
      left: Styles.grid(4),
      bottom: Styles.grid(3),
      right: Styles.grid(4)
    )
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
    |> \.alignment .~ UIStackView.Alignment.fill
    |> \.spacing .~ Styles.grid(4)
}
