import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift

protocol RewardCellDelegate: AnyObject {
  func rewardCellDidTapPledgeButton(_ rewardCell: RewardCell, rewardId: Int)
}

final class RewardCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties

  public weak var delegate: RewardCellDelegate?

  private let rewardCardContainerView = RewardCardContainerView(frame: .zero)
  private let scrollView = UIScrollView(frame: .zero)

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Private Helpers

  private func configureViews() {
    _ = (self.scrollView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rewardCardContainerView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.rewardCardContainerView.delegate = self

    self.setupConstraints()
  }

  private func setupConstraints() {
    self.rewardCardContainerView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor)
      .isActive = true

    self.rewardCardContainerView.pinPledgeButton(to: self.contentView.layoutMarginsGuide)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.scrollView
      |> scrollViewStyle
  }

  internal func configureWith(value: (project: Project, reward: Either<Reward, Backing>)) {
    self.rewardCardContainerView.configure(with: value)
  }
}

extension RewardCell: RewardCardViewDelegate {
  func rewardCardView(_: RewardCardView, didTapWithRewardId rewardId: Int) {
    self.delegate?.rewardCellDidTapPledgeButton(self, rewardId: rewardId)
  }
}

// MARK: - Styles

private let contentViewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.backgroundColor .~ .ksr_grey_200
}

private let scrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> \.backgroundColor .~ .clear
    |> \.contentInset .~ .init(topBottom: Styles.grid(6))
    |> \.showsVerticalScrollIndicator .~ false
}
