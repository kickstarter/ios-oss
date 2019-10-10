import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

final class ManagePledgeSummaryViewController: UIViewController {
  // MARK: - Properties

  private lazy var backerInfoStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var backerNumberLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var backingDateLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var pledgeAmountSummaryViewController: PledgeAmountSummaryViewController = {
    PledgeAmountSummaryViewController.instantiate()
  }()

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var totalAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalAmountStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var totalLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel = ManagePledgeSummaryViewModel()

  // MARK: - Lifecycle

  public func configureWith(_ project: Project) {
    self.viewModel.configureWith(project)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.backerInfoStackView
      |> backerInfoStackViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.totalAmountStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )

    _ = self.backerNumberLabel
      |> backerNumberLabelStyle

    _ = self.backingDateLabel
      |> backingDateLabelStyle

    _ = self.totalLabel
      |> totalLabelStyle

    _ = self.totalAmountLabel
      |> amountLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configurePledgeAmountSummaryViewWithProject
      .observeForUI()
      .observeValues { [weak self] project in
        self?.pledgeAmountSummaryViewController.configureWith(project)
      }

    self.backerNumberLabel.rac.text = self.viewModel.outputs.backerNumberText
    self.backingDateLabel.rac.text = self.viewModel.outputs.backingDateText
    self.totalAmountLabel.rac.attributedText = self.viewModel.outputs.totalAmountText
  }

  // MARK: - Functions

  private func configureViews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.backerNumberLabel, self.backingDateLabel], self.backerInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.totalLabel, self.totalAmountLabel], self.totalAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.addChild(self.pledgeAmountSummaryViewController)

    _ = ([
      self.backerInfoStackView,
      self.pledgeAmountSummaryViewController.view,
      self.totalAmountStackView
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.pledgeAmountSummaryViewController.didMove(toParent: self)
  }
}

// MARK: - Styles

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
    |> \.numberOfLines .~ 0
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

private let totalLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.black
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in Strings.Total_amount() }
}
