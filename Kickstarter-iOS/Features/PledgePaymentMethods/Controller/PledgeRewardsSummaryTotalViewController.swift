import KsApi
import Library
import Prelude
import UIKit

private enum Constants {
  /// Spacing & Padding
  public static let badgeTopButtonPadding = 6.0
  public static let badgeLeadingTrailingPadding = 8.0
  public static let defaultStackViewSpacing = Styles.grid(1)

  /// Corner radius
  public static let defaultCornerRadius = Styles.grid(1)
}

final class PledgeRewardsSummaryTotalViewController: UIViewController {
  // MARK: - Properties

  private lazy var titleAndTotalStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalConversionLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var confirmationLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var pledgeOverTimeStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var pledgeOverTimeBadgeView: UIView = { UIView(frame: .zero) }()
  private lazy var pledgeOverTimeBadgeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var pledgeOverTimeChargesLabel: UILabel = { UILabel(frame: .zero) }()
  private let viewModel: PledgeSummaryViewModelType = PledgeSummaryViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()
    self.bindStyles()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.titleAndTotalStackView
      |> adaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> titleAndTotalStackViewStyle

    _ = self.totalStackView
      |> totalStackViewStyle(self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory)

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.amountLabel
      |> amountLabelStyle

    _ = self.totalConversionLabel
      |> totalConversionLabelStyle

    applyConfirmationLabelStyle(self.confirmationLabel)

    applyPledgeOverTimeStackViewStyle(self.pledgeOverTimeStackView)
    applyPledgeOverTimeBadgeViewStyle(self.pledgeOverTimeBadgeView)
    applyPledgeOverTimeBadgeLabelStyle(self.pledgeOverTimeBadgeLabel)
    applyPledgeOverTimeChargesLabelStyle(self.pledgeOverTimeChargesLabel)
  }

  // MARK: - Configuration

  private func configureSubviews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (
      [self.titleAndTotalStackView, self.pledgeOverTimeStackView, self.confirmationLabel],
      self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.totalStackView], self.titleAndTotalStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.amountLabel, self.totalConversionLabel], self.totalStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.pledgeOverTimeBadgeView.addSubview(self.pledgeOverTimeBadgeLabel)
    self.pledgeOverTimeStackView.addArrangedSubviews(
      self.pledgeOverTimeBadgeView,
      self.pledgeOverTimeChargesLabel
    )
    self.pledgeOverTimeStackView.isHidden = true

    self.pledgeOverTimeBadgeLabel.text = Strings.Pledge_Over_Time()
  }

  private func setupConstraints() {
    self.pledgeOverTimeBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
    self.pledgeOverTimeBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.pledgeOverTimeBadgeView.setContentHuggingPriority(.required, for: .horizontal)
    self.pledgeOverTimeChargesLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

    NSLayoutConstraint.activate([
      self.pledgeOverTimeBadgeLabel.topAnchor.constraint(
        equalTo: self.pledgeOverTimeBadgeView.topAnchor,
        constant: Constants.badgeTopButtonPadding
      ),
      self.pledgeOverTimeBadgeLabel.bottomAnchor.constraint(
        equalTo: self.pledgeOverTimeBadgeView.bottomAnchor,
        constant: -Constants.badgeTopButtonPadding
      ),
      self.pledgeOverTimeBadgeLabel.leadingAnchor.constraint(
        equalTo: self.pledgeOverTimeBadgeView.leadingAnchor,
        constant: Constants.badgeLeadingTrailingPadding
      ),
      self.pledgeOverTimeBadgeLabel.trailingAnchor.constraint(
        equalTo: self.pledgeOverTimeBadgeView.trailingAnchor,
        constant: -Constants.badgeLeadingTrailingPadding
      )
    ])
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.titleLabelText
      .observeForUI()
      .observeValues { [weak self] text in
        self?.titleLabel.text = text
      }

    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountLabelAttributedText
    self.totalConversionLabel.rac.text = self.viewModel.outputs.totalConversionLabelText

    self.confirmationLabel.rac.hidden = self.viewModel.outputs.confirmationLabelHidden
    self.confirmationLabel.rac.attributedText = self.viewModel.outputs.confirmationLabelAttributedText

    self.pledgeOverTimeStackView.rac.hidden = self.viewModel.outputs.pledgeOverTimeStackViewHidden
    self.pledgeOverTimeChargesLabel.rac.text = self.viewModel.outputs.pledgeOverTimeChargesText
  }

  // MARK: - Configuration

  internal func configure(with data: PledgeSummaryViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  internal func configureWith(pledeOverTimeData: PledgePaymentPlansAndSelectionData?) {
    self.viewModel.inputs.configureWith(pledgeOverTimeData: pledeOverTimeData)
  }
}

// MARK: - Styles

private let amountLabelStyle: LabelStyle = { (label: UILabel) in
  _ = label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.adjustsFontSizeToFitWidth .~ true
    |> \.isAccessibilityElement .~ true
    |> \.minimumScaleFactor .~ 0.75
    |> \.backgroundColor .~ .ksr_white

  return label
}

private let titleAndTotalStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.backgroundColor .~ .ksr_white
    |> \.layoutMargins .~ UIEdgeInsets(leftRight: Styles.gridHalf(4))
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(3)
    |> \.backgroundColor .~ .ksr_white
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(3), leftRight: Styles.grid(4))
}

private let titleLabelStyle: LabelStyle = { (label: UILabel) -> UILabel in
  _ = label
    |> checkoutTitleLabelStyle
    |> \.font .~ .ksr_subhead().bolded
    |> \.backgroundColor .~ .ksr_white

  return label
}

private let totalConversionLabelStyle: LabelStyle = { label in
  _ = label
    |> \.font .~ .ksr_caption1()
    |> \.textColor .~ .ksr_support_400
    |> \.backgroundColor .~ .ksr_white

  return label
}

private func totalStackViewStyle(_ isAccessibilityCategory: Bool) -> StackViewStyle {
  return { stackView in
    stackView
      |> verticalStackViewStyle
      |> \.backgroundColor .~ .ksr_white
      |> \.spacing .~ Styles.grid(1)
      |> \.alignment .~
      (isAccessibilityCategory ? UIStackView.Alignment.leading : UIStackView.Alignment.trailing)
  }
}

private func applyConfirmationLabelStyle(_ label: UILabel) {
  label.numberOfLines = 0
  label.backgroundColor = UIColor.ksr_white
}

private func applyPledgeOverTimeStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.spacing = Constants.defaultStackViewSpacing
  stackView.alignment = .center
}

private func applyPledgeOverTimeBadgeViewStyle(_ view: UIView) {
  view.backgroundColor = .ksr_create_100
  view.rounded(with: Constants.defaultCornerRadius)
}

private func applyPledgeOverTimeBadgeLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_caption1().bolded
  label.textColor = .ksr_create_700
  label.textAlignment = .center
  label.numberOfLines = 1
  label.adjustsFontForContentSizeCategory = true
}

private func applyPledgeOverTimeChargesLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_footnote()
  label.textColor = .ksr_support_700
  label.textAlignment = .right
  label.numberOfLines = 0
  label.adjustsFontForContentSizeCategory = true
}
