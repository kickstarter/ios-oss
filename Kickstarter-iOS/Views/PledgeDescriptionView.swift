import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class PledgeDescriptionView: UIView {
  // MARK: - Properties

  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var estimatedDeliveryStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rewardTitleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: PledgeDescriptionViewModelType = PledgeDescriptionViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutWhiteBackgroundStyle

    _ = self.dateLabel
      |> dateLabelStyle

    _ = self.estimatedDeliveryLabel
      |> estimatedDeliveryLabelStyle

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.estimatedDeliveryStackView
      |> estimatedDeliveryStackViewStyle(isAccessibilityCategory)

    _ = self.rewardTitleLabel
      |> rewardTitleLabelStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()

    _ = ([self.estimatedDeliveryLabel, self.dateLabel, UIView()], self.estimatedDeliveryStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.estimatedDeliveryStackView, self.rewardTitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self)
      |> ksr_constrainViewToEdgesInParent()
  }

  // MARK: - Actions

  @objc private func rewardCardTapped() {
    self.viewModel.inputs.rewardCardTapped()
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.dateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryText
    self.estimatedDeliveryStackView.rac.hidden = self.viewModel.outputs.estimatedDeliveryStackViewIsHidden

    self.viewModel.outputs.rewardTitle
      .observeForUI()
      .observeValues { [weak self] title in
        _ = self?.rewardTitleLabel
          ?|> \.text .~ title
      }
  }

  // MARK: - Configuration

  internal func configureWith(value: (project: Project, reward: Reward)) {
    self.viewModel.inputs.configureWith(data: value)
  }
}

// MARK: Styles

private let dateLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_caption1()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.minimumScaleFactor .~ 0.5
}

private let estimatedDeliveryLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text %~ { _ in Strings.Estimated_delivery() }
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_caption1()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.minimumScaleFactor .~ 0.5
}

private func estimatedDeliveryStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    stackView
      |> adaptableStackViewStyle(isAccessibilityCategory)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.spacing .~ Styles.grid(1)
      |> \.distribution .~ .fill
      |> \.alignment .~ .leading
  }
}

private let rewardTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.numberOfLines .~ 2
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.spacing .~ Styles.grid(1)
    |> verticalStackViewStyle
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(3), leftRight: Styles.grid(3))
}
