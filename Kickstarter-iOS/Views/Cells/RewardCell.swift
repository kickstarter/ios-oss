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
  private let viewModel: RewardCellViewModelType = RewardCellViewModel()

  private let containerView = UIView(frame: .zero)
  private let pledgeButton: MultiLineButton = {
    MultiLineButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let pledgeButtonLayoutGuide = UILayoutGuide()
  public let rewardCardView: RewardCardView = {
    RewardCardView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

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

    _ = (self.containerView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rewardCardView, self.containerView)
      |> ksr_addSubviewToParent()

    _ = (self.pledgeButtonLayoutGuide, self.containerView)
      |> ksr_addLayoutGuideToView()

    _ = (self.pledgeButton, self.containerView)
      |> ksr_addSubviewToParent()

    self.rewardCardView.delegate = self
    self.pledgeButton.addTarget(self, action: #selector(self.pledgeButtonTapped), for: .touchUpInside)

    self.setupConstraints()
  }

  private func setupConstraints() {
    let containerConstraints = [
      self.containerView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor)
    ]

    let containerMargins = self.containerView.layoutMarginsGuide

    let rewardCardViewConstraints = [
      self.rewardCardView.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
      self.rewardCardView.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
      self.rewardCardView.topAnchor.constraint(equalTo: containerMargins.topAnchor)
    ]

    let topConstraint = self.pledgeButton.topAnchor
      .constraint(equalTo: self.pledgeButtonLayoutGuide.topAnchor)
      |> \.priority .~ .defaultLow

    let contentMargins = self.contentView.layoutMarginsGuide

    let pledgeButtonConstraints = [
      topConstraint,
      self.pledgeButton.leftAnchor.constraint(equalTo: contentMargins.leftAnchor),
      self.pledgeButton.rightAnchor.constraint(equalTo: contentMargins.rightAnchor),
      self.pledgeButton.bottomAnchor.constraint(lessThanOrEqualTo: contentMargins.bottomAnchor),
      self.pledgeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ]

    let pledgeButtonLayoutGuideConstraints = [
      self.pledgeButtonLayoutGuide.bottomAnchor.constraint(equalTo: containerMargins.bottomAnchor),
      self.pledgeButtonLayoutGuide.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
      self.pledgeButtonLayoutGuide.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
      // swiftlint:disable:next line_length
      self.pledgeButtonLayoutGuide.topAnchor.constraint(equalTo: self.rewardCardView.bottomAnchor, constant: Styles.grid(3)),
      self.pledgeButtonLayoutGuide.heightAnchor.constraint(equalTo: pledgeButton.heightAnchor)
    ]

    NSLayoutConstraint.activate([
      containerConstraints,
      rewardCardViewConstraints,
      pledgeButtonConstraints,
      pledgeButtonLayoutGuideConstraints
    ]
    .flatMap { $0 })
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.containerView
      |> checkoutWhiteBackgroundStyle
      |> roundedStyle(cornerRadius: Styles.grid(3))
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.pledgeButton
      |> checkoutGreenButtonStyle

    _ = self.pledgeButton.titleLabel
      ?|> checkoutGreenButtonTitleLabelStyle

    _ = self.scrollView
      |> scrollViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.pledgeButton.rac.title = self.viewModel.outputs.pledgeButtonTitleText
    self.pledgeButton.rac.enabled = self.viewModel.outputs.pledgeButtonEnabled

    self.viewModel.outputs.rewardSelected
      .observeForUI()
      .observeValues { [weak self] rewardId in
        guard let self = self else { return }

        self.delegate?.rewardCellDidTapPledgeButton(self, rewardId: rewardId)
      }
  }

  internal func configureWith(value: (project: Project, reward: Either<Reward, Backing>)) {
    self.viewModel.inputs.configureWith(project: value.project, rewardOrBacking: value.reward)
    self.rewardCardView.configure(with: value)
  }

  // MARK: - Selectors

  @objc func pledgeButtonTapped() {
    self.viewModel.inputs.pledgeButtonTapped()
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
