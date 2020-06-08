import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

final class PledgeAmountSummaryViewController: UIViewController {
  // MARK: Properties

  private lazy var pledgeAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var pledgeAmountStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var pledgeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var shippingAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingLocationLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingLocationStackView: UIStackView = { UIStackView(frame: .zero) }()

  private let viewModel: PledgeAmountSummaryViewModelType = PledgeAmountSummaryViewModel()

  // MARK: Life cycle

  public func configureWith(_ data: PledgeAmountSummaryViewData) {
    self.viewModel.inputs.configureWith(data)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: Styles

  override func bindStyles() {
    super.bindStyles()

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.pledgeAmountStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.shippingLocationStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)

    _ = self.pledgeLabel
      |> pledgeLabelStyle

    _ = self.pledgeAmountLabel
      |> amountLabelStyle

    _ = self.shippingLocationLabel
      |> shippingLocationLabelStyle

    _ = self.shippingAmountLabel
      |> amountLabelStyle
  }

  // MARK: View model

  override func bindViewModel() {
    super.bindViewModel()

    self.pledgeAmountLabel.rac.attributedText = self.viewModel.outputs.pledgeAmountText
    self.shippingAmountLabel.rac.attributedText = self.viewModel.outputs.shippingAmountText
    self.shippingLocationLabel.rac.text = self.viewModel.outputs.shippingLocationText
    self.shippingLocationStackView.rac.hidden = self.viewModel.outputs.shippingLocationStackViewIsHidden
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.pledgeLabel, self.pledgeAmountLabel], self.pledgeAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.pledgeAmountLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.shippingAmountLabel.setContentHuggingPriority(.required, for: .horizontal)

    _ = ([self.shippingLocationLabel, self.shippingAmountLabel], self.shippingLocationStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([
      self.pledgeAmountStackView,
      self.shippingLocationStackView
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}

// MARK: Styles

private let amountLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.isAccessibilityElement .~ true
    |> \.minimumScaleFactor .~ 0.75
}

private let pledgeLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_dark_grey_500
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in Strings.Pledge() }
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> checkoutStackViewStyle
    |> \.spacing .~ Styles.grid(3)
}

private let shippingLocationLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_dark_grey_500
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}
