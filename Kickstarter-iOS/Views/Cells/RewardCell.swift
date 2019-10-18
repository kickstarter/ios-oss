import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift

protocol RewardCellDelegate: AnyObject {
  func rewardCellDidTapPledgeButton(_ rewardCell: RewardCell, rewardId: Int)
  func rewardCell(_ rewardCell: RewardCell, shouldShowDividerLine show: Bool)
}

final class RewardCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties

  internal weak var delegate: RewardCellDelegate?
  private let viewModel: RewardCellViewModelType = RewardCellViewModel()

  internal let rewardCardContainerView = RewardCardContainerView(frame: .zero)
  private lazy var scrollView = {
    UIScrollView(frame: .zero)
      |> \.delegate .~ self
  }()

  private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
    UILongPressGestureRecognizer(
      target: self, action: #selector(RewardCell.depress(_:))
    )
      |> \.minimumPressDuration .~ CheckoutConstants.RewardCard.Transition
      .DepressAnimation.longPressMinimumDuration
      |> \.delegate .~ self
      |> \.cancelsTouchesInView .~ false
      |> \.isEnabled .~ false // FIXME: remove once we're ready to handle the transition again
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.scrollScrollViewToTop
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }

        self.scrollView.setContentOffset(
          .init(
            x: self.scrollView.contentOffset.x,
            y: -self.scrollView.contentInset.top
          ),
          animated: false
        )
      }
  }

  // MARK: - Functions

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
    self.rewardCardContainerView.pinBottomViews(to: self.contentView.layoutMarginsGuide)

    NSLayoutConstraint.activate([
      self.rewardCardContainerView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
      self.rewardCardContainerView.gradientView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
      self.rewardCardContainerView.gradientView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
      self.rewardCardContainerView.gradientView.bottomAnchor
        .constraint(lessThanOrEqualTo: self.contentView.bottomAnchor)
    ])
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle
      |> rewardsBackgroundStyle

    _ = self.scrollView
      |> scrollViewStyle
  }

  internal func configureWith(value: (project: Project, reward: Either<Reward, Backing>)) {
    self.rewardCardContainerView.configure(with: value)
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    self.viewModel.inputs.prepareForReuse()
  }

  // MARK: - Accessors

  func currentReward(is reward: Reward) -> Bool {
    return self.rewardCardContainerView.currentReward(is: reward)
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

      _ = self.rewardCardContainerView
        |> \.transform .~ transform
    }

    animator.startAnimation()
  }
}

extension RewardCell: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollViewTopInset = scrollView.contentInset.top

    let cardContainerViewY = self.rewardCardContainerView.frame.origin.y
    let yOffset = scrollView.contentOffset.y - scrollViewTopInset - cardContainerViewY
    let showDivider = yOffset + scrollViewTopInset >= 0

    self.delegate?.rewardCell(self, shouldShowDividerLine: showDivider)
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
}

private let scrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> \.backgroundColor .~ .clear
    |> \.contentInset .~ .init(topBottom: Styles.grid(6))
    |> \.showsVerticalScrollIndicator .~ false
    |> \.contentInsetAdjustmentBehavior .~ UIScrollView.ContentInsetAdjustmentBehavior.never
}
