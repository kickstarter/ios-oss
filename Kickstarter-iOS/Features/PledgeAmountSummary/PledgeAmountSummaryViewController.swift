import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

final class PledgeAmountSummaryViewController: UIViewController {
  // MARK: Properties

  private lazy var bonusAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var bonusAmountStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var bonusLabel: UILabel = { UILabel(frame: .zero) }()
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

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.bonusAmountStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)

    _ = self.pledgeAmountStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)

    _ = self.shippingLocationStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)

    _ = self.bonusLabel
      |> titleLabelStyle
      |> \.text %~ { _ in Strings.Bonus() }

    _ = self.pledgeLabel
      |> titleLabelStyle
      |> \.text %~ { _ in Strings.Pledge() }

    _ = self.pledgeAmountLabel
      |> amountLabelStyle

    _ = self.shippingLocationLabel
      |> titleLabelStyle

    _ = self.shippingAmountLabel
      |> amountLabelStyle
  }

  // MARK: View model

  override func bindViewModel() {
    super.bindViewModel()

    self.bonusAmountLabel.rac.attributedText = self.viewModel.outputs.bonusAmountText
    self.bonusAmountStackView.rac.hidden = self.viewModel.outputs.bonusAmountStackViewIsHidden
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

    _ = ([self.bonusLabel, self.bonusAmountLabel], self.bonusAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.bonusAmountLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.pledgeAmountLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.shippingAmountLabel.setContentHuggingPriority(.required, for: .horizontal)

    _ = ([self.shippingLocationLabel, self.shippingAmountLabel], self.shippingLocationStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([
      self.pledgeAmountStackView,
      self.shippingLocationStackView,
      self.bonusAmountStackView
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

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_support_400
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> checkoutStackViewStyle
    |> \.spacing .~ Styles.grid(3)
}
