import Foundation
import KsApi
import Library
import Prelude

final class RewardCell: UICollectionViewCell, ValueCell {
  private let containerView = UIView(frame: .zero)

  override init(frame: CGRect) {
    super.init(frame: frame)

    configureViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureViews() {
    _ = self.contentView
      |> \.backgroundColor .~ .red
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = containerView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.backgroundColor .~ UIColor.white
      |> roundedStyle(cornerRadius: 12)

    _ = (self.containerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  func configureWith(value: Reward) {

  }
}
