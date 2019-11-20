import KsApi
import Library
import Prelude
import UIKit

final class ManagePledgeRewardView: UIView {
  // MARK: - Properties

  private lazy var rewardView: RewardCardView = {
    RewardCardView(frame: .zero)
  }()

  private lazy var backgroundView: UIView = { UIView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Life cycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindStyles()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public func configure(with value: (Project, Either<Reward, Backing>)) {
    self.rewardView.configure(with: value)
  }

  private func configureViews() {
    _ = (self.rewardView, self.backgroundView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.titleLabel, self.backgroundView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.backgroundView
      |> backgroundViewStyle

    _ = self.rootStackView
      |> checkoutCardStackViewStyle

    _ = self.titleLabel
      |> titleLabelStyle
  }
}

// MARK: - Styles

private let titleLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.text %~ { _ in Strings.Selected_reward() }
}

private let backgroundViewStyle: ViewStyle = { (view: UIView) in
  view
    |> checkoutWhiteBackgroundStyle
    |> roundedStyle(cornerRadius: Styles.grid(3))
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}
