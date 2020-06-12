import KsApi
import Library
import Prelude
import UIKit

protocol PledgeShippingLocationViewControllerDelegate: AnyObject {
  func pledgeShippingLocationViewController(
    _ viewController: PledgeShippingLocationViewController,
    didSelect shippingRule: ShippingRule
  )
}

final class PledgeShippingLocationViewController: UIViewController {
  // MARK: - Properties

  public weak var delegate: PledgeShippingLocationViewControllerDelegate?
  private let viewModel: PledgeShippingLocationViewModelType = PledgeShippingLocationViewModel()

  private lazy var adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingLocationButton: UIButton = { UIButton(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var shimmerLoadingView: PledgeShippingLocationShimmerLoadingView = {
    PledgeShippingLocationShimmerLoadingView(frame: .zero)
  }()

  private lazy var spacer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.accessibilityElements .~ [self.titleLabel, self.shippingLocationButton, self.amountLabel]

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.adaptableStackView, self.shimmerLoadingView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.shippingLocationButton, self.spacer, self.amountLabel], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.shippingLocationButton.addTarget(
      self,
      action: #selector(PledgeShippingLocationViewController.shippingLocationButtonTapped(_:)),
      for: .touchUpInside
    )

    self.spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(3)).isActive = true

    self.amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.adaptableStackView
      |> adaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )

    _ = self.amountLabel
      |> checkoutBackgroundStyle
    _ = self.amountLabel
      |> amountLabelStyle

    _ = self.shippingLocationButton
      |> countryButtonStyle
      |> checkoutWhiteBackgroundStyle
      |> checkoutRoundedCornersStyle

    _ = self.shippingLocationButton.titleLabel
      ?|> countryButtonTitleLabelStyle

    _ = self.titleLabel
      |> checkoutBackgroundStyle
    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Your_shipping_location() }

    _ = self.rootStackView
      |> checkoutStackViewStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.adaptableStackView.rac.hidden = self.viewModel.outputs.adaptableStackViewIsHidden
    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountAttributedText
    self.shimmerLoadingView.rac.hidden = self.viewModel.outputs.shimmerLoadingViewIsHidden
    self.shippingLocationButton.rac.title = self.viewModel.outputs.shippingLocationButtonTitle

    self.viewModel.outputs.notifyDelegateOfSelectedShippingRule
      .observeForUI()
      .observeValues { [weak self] shippingRule in
        guard let self = self else { return }

        self.delegate?.pledgeShippingLocationViewController(self, didSelect: shippingRule)
      }

    self.viewModel.outputs.presentShippingRules
      .observeForUI()
      .observeValues { [weak self] project, shippingRules, selectedShippingRule in
        self?.presentShippingRules(
          project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule
        )
      }

    self.viewModel.outputs.dismissShippingRules
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismiss(animated: true)
      }
  }

  // MARK: - Configuration

  func configureWith(value: (project: Project, reward: Reward)) {
    self.viewModel.inputs.configureWith(project: value.project, reward: value.reward)
  }

  // MARK: - Actions

  @objc private func shippingLocationButtonTapped(_: UIButton) {
    self.viewModel.inputs.shippingLocationButtonTapped()
  }

  // MARK: - Functions

  private func presentShippingRules(
    _ project: Project, shippingRules: [ShippingRule], selectedShippingRule: ShippingRule
  ) {
    let viewController = ShippingRulesTableViewController.instantiate()
    viewController.configureWith(
      project, shippingRules: shippingRules,
      selectedShippingRule: selectedShippingRule
    )
    viewController.delegate = self

    let navigationController = UINavigationController(rootViewController: viewController)

    self.presentViewControllerWithSheetOverlay(navigationController, offset: Layout.Sheet.offset)
  }
}

extension PledgeShippingLocationViewController: ShippingRulesTableViewControllerDelegate {
  func shippingRulesTableViewControllerCancelButtonTapped() {
    self.viewModel.inputs.shippingRulesCancelButtonTapped()
  }

  func shippingRulesTableViewController(
    _: ShippingRulesTableViewController,
    didSelect shippingRule: ShippingRule
  ) {
    self.viewModel.inputs.shippingRuleUpdated(to: shippingRule)
  }
}

// MARK: - Styles

private let amountLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let countryButtonStyle: ButtonStyle = { (button: UIButton) in
  button
    |> \.contentEdgeInsets .~ UIEdgeInsets(
      topBottom: Styles.grid(1) + Styles.gridHalf(1), leftRight: Styles.grid(2)
    )
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_body().bolded
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_green_500
    |> UIButton.lens.titleColor(for: .highlighted) .~ UIColor.ksr_green_700
}

private let countryButtonTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.lineBreakMode .~ .byTruncatingTail
}
