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

  internal weak var delegate: RewardCellDelegate?

  internal let rewardCardContainerView = RewardCardContainerView(frame: .zero)
  private let scrollView = UIScrollView(frame: .zero)
  private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
    UILongPressGestureRecognizer(
      target: self, action: #selector(RewardCell.depress(_:))
    )
      |> \.minimumPressDuration .~ CheckoutConstants.RewardCard.Transition
      .DepressAnimation.longPressMinimumDuration
      |> \.delegate .~ self
      |> \.cancelsTouchesInView .~ false
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
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

    self.addGestureRecognizer(self.longPressGestureRecognizer)

    self.setupConstraints()
  }

  private func setupConstraints() {
    _ = self.rewardCardContainerView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor)
      |> \.isActive .~ true

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

  // MARK: - Accessors

  func currentReward(is reward: Reward) -> Bool {
    return self.rewardCardContainerView.currentReward(is: reward)
  }

  func cancelDepress() {
    _ = self.longPressGestureRecognizer
      |> \.isEnabled .~ false
    _ = self.longPressGestureRecognizer
      |> \.isEnabled .~ true
  }

  // MARK: - Depress Transform

  @objc func depress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    let animator = UIViewPropertyAnimator(
      duration: CheckoutConstants.RewardCard.Transition.DepressAnimation.duration,
      curve: .linear
    ) {
      let transform: CGAffineTransform
      switch gestureRecognizer.state {
      case .changed:
        return
      case .began:
        let scale = CheckoutConstants.RewardCard.Transition.DepressAnimation.scaleFactor
        transform = CGAffineTransform(scaleX: scale, y: scale)
      default:
        transform = .identity
      }

      _ = self
        |> \.transform .~ transform
    }

    animator.startAnimation()
  }
}

// MARK: - RewardCardViewDelegate

extension RewardCell: RewardCardViewDelegate {
  func rewardCardView(_: RewardCardView, didTapWithRewardId rewardId: Int) {
    self.delegate?.rewardCellDidTapPledgeButton(self, rewardId: rewardId)
  }
}

// MARK: - UIGestureRecognizerDelegate

extension RewardCell: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer
  ) -> Bool {
    return true
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
