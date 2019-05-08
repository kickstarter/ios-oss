import Foundation
import KsApi
import Library
import Prelude

final class RewardCell: UICollectionViewCell, ValueCell {
  private let containerView = UIView(frame: .zero)

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureViews() {
    _ = self.contentView
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.containerView
      |> checkoutWhiteBackgroundStyle
      |> roundedStyle(cornerRadius: Styles.grid(3))

    _ = (self.containerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  func configureWith(value: Reward) {}
}
