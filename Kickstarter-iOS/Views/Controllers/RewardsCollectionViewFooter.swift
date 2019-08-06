import Foundation
import UIKit
import Library
import Prelude

final class RewardsCollectionViewFooter: UICollectionReusableView {
  private lazy var countLabel: UILabel = { UILabel(frame: .zero) }()
  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureSubviews() {
    _ = self
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = (self.countLabel, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.countLabel
      |> countLabelStyle
  }

  // MARK: - Accessors

  public func configure(with rewardsCount: Int) {
    _ = self.countLabel
      |> \.text %~ { _ in Strings.Rewards_count_rewards(rewards_count: rewardsCount) }
  }
}

private let countLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_callout()
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.textAlignment .~ .center
}
