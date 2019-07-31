import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift

public final class RewardCardContainerView: UIView {
  internal var delegate: RewardCardViewDelegate? {
    didSet {
      self.rewardCardView.delegate = self.delegate
    }
  }

  // MARK: - Properties

  private let viewModel: RewardCardContainerViewModelType = RewardCardContainerViewModel()

  private let gradientView: GradientView = {
    GradientView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let pledgeButton: MultiLineButton = {
    MultiLineButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let pledgeButtonLayoutGuide = UILayoutGuide()
  private var pledgeButtonMarginConstraints: [NSLayoutConstraint]?
  private let rewardCardView: RewardCardView = {
    RewardCardView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutWhiteBackgroundStyle
      |> roundedStyle(cornerRadius: Styles.grid(3))
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.pledgeButton
      |> roundedGreenButtonStyle

    _ = self.gradientView
      |> \.backgroundColor .~ .clear
      |> \.startPoint .~ .zero
      |> \.endPoint .~ CGPoint(x: 0, y: 1)

    let gradient: [(UIColor?, Float)] = [
      (UIColor.white.withAlphaComponent(0.1), 0.0),
      (UIColor.white.withAlphaComponent(1.0), 1)
    ]
    self.gradientView.setGradient(gradient)

    _ = self.pledgeButton.titleLabel
      ?|> \.lineBreakMode .~ .byTruncatingTail
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.rewardSelected
      .observeForUI()
      .observeValues { [weak self] rewardId in
        guard let self = self else { return }

        self.rewardCardView.delegate?
          .rewardCardView(self.rewardCardView, didTapWithRewardId: rewardId)
      }

    self.pledgeButton.rac.title = self.viewModel.outputs.pledgeButtonTitleText
    self.pledgeButton.rac.enabled = self.viewModel.outputs.pledgeButtonEnabled
  }

  internal func configure(with value: (project: Project, reward: Either<Reward, Backing>)) {
    self.viewModel.inputs.configureWith(project: value.project, rewardOrBacking: value.reward)
    self.rewardCardView.configure(with: value)
  }

  // MARK: - Private Helpers

  private func configureViews() {
    _ = (self.rewardCardView, self)
      |> ksr_addSubviewToParent()

    _ = (self.gradientView, self)
      |> ksr_addSubviewToParent()

    _ = (self.pledgeButtonLayoutGuide, self)
      |> ksr_addLayoutGuideToView()

    _ = (self.pledgeButton, self)
      |> ksr_addSubviewToParent()

    self.setupConstraints()

    self.pledgeButton.addTarget(self, action: #selector(self.pledgeButtonTapped), for: .touchUpInside)
  }

  public func setupConstraints() {
    let containerMargins = self.layoutMarginsGuide

    let rewardCardViewConstraints = [
      self.rewardCardView.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
      self.rewardCardView.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
      self.rewardCardView.topAnchor.constraint(equalTo: containerMargins.topAnchor)
    ]

    let pledgeButtonTopConstraint = self.pledgeButton.topAnchor
      .constraint(equalTo: self.pledgeButtonLayoutGuide.topAnchor)
      |> \.priority .~ .defaultLow

    // sometimes this is provided by the parent cell for pinning of the button
    self.addBottomViewsMarginConstraints(with: self.layoutMarginsGuide)

    let pledgeButtonLayoutGuideConstraints = [
      self.pledgeButtonLayoutGuide.bottomAnchor.constraint(equalTo: containerMargins.bottomAnchor),
      self.pledgeButtonLayoutGuide.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
      self.pledgeButtonLayoutGuide.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
      // swiftlint:disable:next line_length
      self.pledgeButtonLayoutGuide.topAnchor.constraint(equalTo: self.rewardCardView.bottomAnchor, constant: Styles.grid(3)),
      self.pledgeButtonLayoutGuide.heightAnchor.constraint(equalTo: self.pledgeButton.heightAnchor)
    ]

    NSLayoutConstraint.activate([
      [pledgeButtonTopConstraint],
      rewardCardViewConstraints,
      pledgeButtonLayoutGuideConstraints
    ]
    .flatMap { $0 })
  }

  private func addBottomViewsMarginConstraints(with layoutMarginsGuide: UILayoutGuide) {
    NSLayoutConstraint.deactivate(self.pledgeButtonMarginConstraints ?? [])
    let minTouchSize = Styles.minTouchSize.height

    NSLayoutConstraint.activate([
      self.pledgeButton.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
      self.pledgeButton.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
      self.pledgeButton.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
      self.pledgeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: minTouchSize)
    ])

    NSLayoutConstraint.activate([
      self.gradientView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
      self.gradientView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
      self.gradientView.topAnchor.constraint(equalTo: self.pledgeButton.topAnchor, constant: -minTouchSize),
      // swiftlint:disable:next line_length
      self.gradientView.bottomAnchor.constraint(equalTo: self.pledgeButton.bottomAnchor, constant: minTouchSize / 2)
    ])
  }

  // MARK: - Accessors

  public func pinBottomViews(to layoutMarginsGuide: UILayoutGuide) {
    self.addBottomViewsMarginConstraints(with: layoutMarginsGuide)
  }

  public func currentReward(is reward: Reward) -> Bool {
    return self.viewModel.outputs.currentReward(is: reward)
  }

  // MARK: - Selectors

  @objc func pledgeButtonTapped() {
    self.viewModel.inputs.pledgeButtonTapped()
  }
}
