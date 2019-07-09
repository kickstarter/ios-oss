import KsApi
import Library
import Prelude
import UIKit

protocol PledgeShippingLocationCellDelegate: AnyObject {
  func pledgeShippingCellWillPresentShippingRules(
    _ cell: PledgeShippingLocationCell, selectedShippingRule rule: ShippingRule
  )
}

final class PledgeShippingLocationCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  public weak var delegate: PledgeShippingLocationCellDelegate?
  private let viewModel: PledgeShippingLocationCellViewModelType = PledgeShippingLocationCellViewModel()

  private lazy var adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingLocationButton: UIButton = { UIButton(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var spacer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    _ = self
      |> \.accessibilityElements .~ [self.titleLabel, self.shippingLocationButton, self.amountLabel]

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.adaptableStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.shippingLocationButton, self.spacer, self.amountLabel], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.shippingLocationButton.addTarget(
      self,
      action: #selector(PledgeShippingLocationCell.shippingLocationButtonTapped(_:)),
      for: .touchUpInside
    )

    self.spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(3)).isActive = true

    self.amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutBackgroundStyle

    _ = self.adaptableStackView
      |> checkoutAdaptableStackViewStyle(
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

  // MARK: - Binding

  override func bindViewModel() {
    super.bindViewModel()

    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountAttributedText
    self.shippingLocationButton.rac.title = self.viewModel.outputs.shippingLocationButtonTitle

    self.viewModel.outputs.selectedShippingLocation
      .observeForUI()
      .observeValues { [weak self] shippingRule in
        guard let self = self else { return }
        self.delegate?.pledgeShippingCellWillPresentShippingRules(self, selectedShippingRule: shippingRule)
      }
  }

  // MARK: - Configuration

  func configureWith(value: (isLoading: Bool, project: Project, selectedShippingRule: ShippingRule?)) {
    self.viewModel.inputs.configureWith(
      isLoading: value.isLoading,
      project: value.project,
      selectedShippingRule: value.selectedShippingRule
    )
  }

  // MARK: - Actions

  @objc func shippingLocationButtonTapped(_: UIButton) {
    self.viewModel.inputs.shippingLocationButtonTapped()
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
