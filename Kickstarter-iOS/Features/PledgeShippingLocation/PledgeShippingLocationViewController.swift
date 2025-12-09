import KDS
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol PledgeShippingLocationViewControllerDelegate: AnyObject {
  func pledgeShippingLocationViewController(
    _ viewController: PledgeShippingLocationViewController,
    didSelect location: Location
  )
  func pledgeShippingLocationViewControllerLayoutDidUpdate(
    _ viewController: PledgeShippingLocationViewController,
    _ shimmerLoadingViewIsHidden: Bool
  )
  func pledgeShippingLocationViewControllerFailedToLoad(
    _ viewController: PledgeShippingLocationViewController
  )
}

final class PledgeShippingLocationViewController: UIViewController {
  // MARK: - Properties

  public weak var delegate: PledgeShippingLocationViewControllerDelegate?
  private let viewModel: PledgeShippingLocationViewModelType = PledgeShippingLocationViewModel()

  private lazy var adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
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
      |> \.accessibilityElements .~ [self.titleLabel, self.shippingLocationButton]

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.adaptableStackView, self.shimmerLoadingView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.shippingLocationButton, self.spacer], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.shippingLocationButton.addTarget(
      self,
      action: #selector(PledgeShippingLocationViewController.shippingLocationButtonTapped(_:)),
      for: .touchUpInside
    )

    self.spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(3)).isActive = true

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
    self.shimmerLoadingView.rac.hidden = self.viewModel.outputs.shimmerLoadingViewIsHidden
    self.shippingLocationButton.rac.title = self.viewModel.outputs.shippingLocationButtonTitle

    /**
     When any layout updates occur we need to notify the delegate. This is only necessary when
     this view is contained within a view that is not fully supported by Auto Layout,
     e.g. a `UITableView` header.
     */
    Signal.combineLatest(
      self.viewModel.outputs.adaptableStackViewIsHidden,
      self.viewModel.outputs.shimmerLoadingViewIsHidden,
      self.viewModel.outputs.shippingLocationButtonTitle
    )
    .observeForUI()
    .observeValues { [weak self] _, shimmerLoadingViewIsHidden, _ in
      guard let self = self else { return }
      self.delegate?.pledgeShippingLocationViewControllerLayoutDidUpdate(self, shimmerLoadingViewIsHidden)
    }

    self.viewModel.outputs.notifyDelegateOfSelectedShippingLocation
      .observeForUI()
      .observeValues { [weak self] location in
        guard let self = self else { return }

        self.delegate?.pledgeShippingLocationViewController(self, didSelect: location)
      }

    self.viewModel.outputs.presentShippingLocations
      .observeForUI()
      .observeValues { [weak self] locations, location in
        self?.presentShippingLocations(
          locations: locations, selectedLocation: location
        )
      }

    self.viewModel.outputs.dismissShippingLocations
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismiss(animated: true)
      }

    self.viewModel.outputs.shippingRulesError
      .observeForUI()
      .observeValues { [weak self] _ in
        guard let self = self else { return }

        self.delegate?.pledgeShippingLocationViewControllerFailedToLoad(self)
      }
  }

  // MARK: - Configuration

  func configureWith(value: PledgeShippingLocationViewData) {
    self.viewModel.inputs.configureWith(data: value)
  }

  // MARK: - Actions

  @objc private func shippingLocationButtonTapped(_: UIButton) {
    self.viewModel.inputs.shippingLocationButtonTapped()
  }

  // MARK: - Functions

  private func presentShippingLocations(
    locations: [Location],
    selectedLocation: Location
  ) {
    let viewController = ShippingLocations.viewController(
      withLocations: locations,
      selectedLocation: selectedLocation,
      onSelectedLocation: { self.viewModel.inputs.shippingLocationUpdated(to: $0) },
      onCancelled: { self.viewModel.inputs.shippingLocationCancelButtonTapped() }
    )
    self.presentViewControllerWithSheetOverlay(viewController, offset: Layout.Sheet.offset)
  }
}

// MARK: - Styles

private let amountLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let countryButtonStyle: ButtonStyle = { (button: UIButton) in
  button
    |> UIButton.lens.contentEdgeInsets .~ UIEdgeInsets(
      top: Styles.gridHalf(3), left: Styles.grid(2), bottom: Styles.gridHalf(3), right: Styles.grid(5)
    )
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_body().bolded
    |> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_create_700.uiColor()
    |> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_create_700.uiColor()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "icon-dropdown-small")
    |> UIButton.lens.semanticContentAttribute .~ .forceRightToLeft
    |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(top: 0, left: Styles.grid(6), bottom: 0, right: 0)
}

private let countryButtonTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.lineBreakMode .~ .byTruncatingTail
}
