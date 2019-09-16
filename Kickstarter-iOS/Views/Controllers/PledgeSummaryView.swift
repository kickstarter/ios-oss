import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

final class PledgeSummaryView: UIView {
  // MARK: Properties

  private lazy var backerInfoStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var backerNumberLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var backingDateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var pledgeAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var pledgeAmountStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var pledgeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var shippingAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingLocationLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingLocationStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var totalAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalAmountStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var totalLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel = PledgeSummaryViewViewModel()

  // MARK: Life cycle

  public func configureWith(_ project: Project) {
    self.viewModel.configureWith(project)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.backerInfoStackView
      |> backerInfoStackViewStyle

    _ = self.pledgeAmountStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.shippingLocationStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )

    _ = self.totalAmountStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )

    _ = self.backerNumberLabel
      |> backerNumberLabelStyle

    _ = self.backingDateLabel
      |> backingDateLabelStyle

    _ = self.pledgeLabel
      |> pledgeLabelStyle

    _ = self.pledgeAmountLabel
      |> amountLabelStyle

    _ = self.shippingLocationLabel
      |> shippingLocationLabelStyle

    _ = self.shippingAmountLabel
      |> amountLabelStyle

    _ = self.totalLabel
      |> totalLabelStyle

    _ = self.totalAmountLabel
      |> amountLabelStyle
  }

  // MARK: View model

  override func bindViewModel() {
    super.bindViewModel()

    self.backerNumberLabel.rac.text = self.viewModel.outputs.backerNumberText
    self.backingDateLabel.rac.text = self.viewModel.outputs.backingDateText
    self.pledgeAmountLabel.rac.attributedText = self.viewModel.outputs.pledgeAmountText
    self.shippingAmountLabel.rac.attributedText = self.viewModel.outputs.shippingAmountText
    self.shippingLocationLabel.rac.text = self.viewModel.outputs.shippingLocationText
    self.shippingLocationStackView.rac.hidden = self.viewModel.outputs.shippingLocationStackViewIsHidden
    self.totalAmountLabel.rac.attributedText = self.viewModel.outputs.totalAmountText
  }

  // MARK: Functions

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.backerNumberLabel, self.backingDateLabel], self.backerInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.pledgeLabel, self.pledgeAmountLabel], self.pledgeAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.shippingLocationLabel, self.shippingAmountLabel], self.shippingLocationStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.totalLabel, self.totalAmountLabel], self.totalAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.backerInfoStackView,
          self.pledgeAmountStackView,
          self.shippingLocationStackView,
          self.totalAmountStackView], self.rootStackView)
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

private let backerInfoStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
}

private let backerNumberLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let backingDateLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_subhead()
    |> \.textColor .~ UIColor.ksr_dark_grey_500
    |> \.adjustsFontForContentSizeCategory .~ true
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
}

private let totalLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.black
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in "Total amount" }
}
