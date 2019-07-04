import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift

final class RewardCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties

  public let rewardCardView: RewardCardView = { RewardCardView(frame: .zero) }()
  private let scrollView = UIScrollView(frame: .zero)

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Private Helpers

  private func configureViews() {
    _ = self.contentView
      |> contentViewStyle

    _ = (self.scrollView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rewardCardView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.setupConstraints()
  }

  private func setupConstraints() {
    self.rewardCardView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.scrollView
      |> scrollViewStyle
  }

  internal func configureWith(value: (Project, Either<Reward, Backing>)) {
    self.rewardCardView.configure(with: value)
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
