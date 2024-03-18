import KsApi
import Library
import Prelude
import UIKit

public enum ConfirmDetailsLayout {
  enum Margin {
    static let topBottom: CGFloat = Styles.grid(3)
    static let leftRight: CGFloat = CheckoutConstants.PledgeView.Inset.leftRight
  }
}

protocol ConfirmDetailsViewControllerDelegate: AnyObject {}

final class ConfirmDetailsViewController: UIViewController {
  // MARK: - Properties

  public weak var delegate: ConfirmDetailsViewControllerDelegate?

  private lazy var titleLabel = UILabel(frame: .zero)

  /// The pledge and bonus steppers used to change the pledge amount
  private lazy var pledgeAmountViewController = {
    PledgeAmountViewController.instantiate()
      |> \.delegate .~ self
  }()

  /// The shipping location shown when changing shipping locations isn't an option
  private lazy var shippingSummaryView: PledgeShippingSummaryView = {
    PledgeShippingSummaryView(frame: .zero)
  }()

  /// The bottom-up modal for selecting a new shipping location
  private lazy var shippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var localPickupLocationView = {
    PledgeLocalPickupView(frame: .zero)
  }()

  private lazy var pledgeSummarySectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  /// Total Pledge Summary. Shown when there is no reward selected
  private lazy var pledgeSummaryViewController: PledgeSummaryViewController = {
    PledgeSummaryViewController.instantiate()
  }()

  private lazy var pledgeAmountSummarySectionViews = {
    [
      self.pledgeSummarySectionSeparator,
      self.pledgeSummaryViewController.view
    ]
  }()

  private lazy var inputsSectionViews = {
    [
      self.shippingLocationViewController.view,
      self.shippingSummaryView,
      self.localPickupLocationView,
      self.pledgeAmountViewController.view
    ]
  }()

  /// The rewards and pledge summary table view
  private lazy var pledgeRewardsSummaryViewController = {
    PostCampaignPledgeRewardsSummaryViewController.instantiate()
  }()

  private lazy var continueCTAView: ConfirmDetailsContinueCTAView = {
    ConfirmDetailsContinueCTAView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var keyboardDimissingTapGestureRecognizer: UITapGestureRecognizer = {
    UITapGestureRecognizer(
      target: self,
      action: #selector(ConfirmDetailsViewController.dismissKeyboard)
    )
      |> \.cancelsTouchesInView .~ false
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

    self.continueCTAView.continueButton.addTarget(
      self,
      action: #selector(self.continueButtonTapped),
      for: .touchUpInside
    )

    self.view.addGestureRecognizer(self.keyboardDimissingTapGestureRecognizer)

    self.configureChildViewControllers()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
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
      self.pledgeAmountViewController,
      self.shippingLocationViewController,
      self.pledgeSummaryViewController,
      self.pledgeRewardsSummaryViewController
    ]

    let arrangedSubviews = [
      self.rootInsetStackView
    ]

    let arrangedInsetSubviews = [
      [self.titleLabel],
      self.inputsSectionViews,
      self.pledgeAmountSummarySectionViews,
      [self.pledgeRewardsSummaryViewController.view]
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
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.pledgeSummarySectionSeparator.heightAnchor.constraint(equalToConstant: 1)
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

    _ = self.pledgeSummarySectionSeparator
      |> separatorStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

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

    self.viewModel.outputs.configurePledgeSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeSummaryViewController.configure(with: data)
      }

    self.viewModel.outputs.configurePledgeRewardsSummaryViewWithData
      .observeForUI()
      .observeValues { [weak self] rewardsData, bonusAmount, pledgeData in
        self?.pledgeRewardsSummaryViewController
          .configureWith(rewardsData: rewardsData, bonusAmount: bonusAmount, pledgeData: pledgeData)
      }

    self.viewModel.outputs.configureCTAWithPledgeTotal
      .observeForUI()
      .observeValues { data in
        self.continueCTAView.configure(with: data)
      }

    self.viewModel.outputs.goToCheckout
      .observeForControllerAction()
      .observeValues { [weak self] data in
        guard let self else { return }

        self.goToCheckout(data: data)
      }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.rootScrollView.handleKeyboardVisibilityDidChange(change)
      }

    self.pledgeAmountViewController.view.rac.hidden = self.viewModel.outputs.pledgeAmountViewHidden

    self.shippingLocationViewController.view.rac.hidden = self.viewModel.outputs.shippingLocationViewHidden

    self.shippingSummaryView.rac.hidden = self.viewModel.outputs.shippingSummaryViewHidden

    self.localPickupLocationView.rac.hidden = self.viewModel.outputs.localPickupViewHidden

    self.pledgeSummarySectionSeparator.rac.hidden = self.viewModel.outputs.pledgeSummaryViewHidden
    self.pledgeSummaryViewController.view.rac.hidden = self.viewModel.outputs.pledgeSummaryViewHidden

    self.pledgeRewardsSummaryViewController.view.rac.hidden = self.viewModel.outputs
      .pledgeRewardsSummaryViewHidden

    self.continueCTAView.titleAndAmountStackView.rac.hidden = self.viewModel.outputs
      .pledgeSummaryViewHidden.negate()
  }

  // MARK: - Actions

  @objc func continueButtonTapped() {
    self.viewModel.inputs.continueButtonTapped()
  }

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }

  // MARK: - Functions

  private func goToCheckout(data: PostCampaignCheckoutData) {
    let vc = PostCampaignCheckoutViewController.instantiate()
    vc.configure(with: data)
    vc.title = self.title

    self.navigationController?.pushViewController(vc, animated: true)
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
      topBottom: ConfirmDetailsLayout.Margin.topBottom,
      leftRight: ConfirmDetailsLayout.Margin.leftRight
    )
}
