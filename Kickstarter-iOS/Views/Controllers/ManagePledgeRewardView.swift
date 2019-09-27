import Library
import KsApi
import Prelude
import UIKit

final class ManagePledgeRewardView: UIView {
  // MARK: - Properties

  private lazy var rewardView: RewardCardView = {
    RewardCardView(frame: .zero)
  }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Life cycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindStyles()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public func configure(with value: (Project, Either<Reward, Backing>), context: RewardCardViewContext) {
    self.rewardView.configure(with: value, context: context)
  }

  private func configureViews() {
    _ = self
      |> \.accessibilityElements .~ self.subviews

    _ = ([self.titleLabel, self.rewardView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rewardView
      |> rewardViewStyle

    _ = self.rootStackView
      |> checkoutCardStackViewStyle

    _ = self.titleLabel
      |> titleLabelStyle
  }
}

// MARK: - Styles

private let rewardViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ UIColor.ksr_grey_400
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.black
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
    |> \.text %~ { _ in Strings.Selected_reward() }
}
