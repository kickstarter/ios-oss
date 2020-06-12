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

  private let viewModel: RewardCardContainerViewModelType = RewardCardContainerViewModel()

  // MARK: - Properties

  private let pledgeButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let pledgeButtonLayoutGuide = UILayoutGuide()
  private var pledgeButtonMarginConstraints: [NSLayoutConstraint]?
  private var pledgeButtonShownConstraints: [NSLayoutConstraint] = []
  private var pledgeButtonHiddenConstraints: [NSLayoutConstraint] = []
  private let rewardCardView: RewardCardView = {
    RewardCardView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()

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

    self.viewModel.outputs.pledgeButtonTitleText.observeValues { [weak self] text in
      self?.pledgeButton.setTitle(text, for: .normal)
    }
    self.pledgeButton.rac.enabled = self.viewModel.outputs.pledgeButtonEnabled
    self.pledgeButton.rac.hidden = self.viewModel.outputs.pledgeButtonHidden

    self.viewModel.outputs.pledgeButtonHidden.observeValues { [weak self] hidden in
      guard let self = self else { return }

      if hidden {
        NSLayoutConstraint.deactivate(self.pledgeButtonShownConstraints)
        NSLayoutConstraint.activate(self.pledgeButtonHiddenConstraints)
      } else {
        NSLayoutConstraint.deactivate(self.pledgeButtonHiddenConstraints)
        NSLayoutConstraint.activate(self.pledgeButtonShownConstraints)
      }
    }

    self.viewModel.outputs.pledgeButtonStyleType
      .observeForUI()
      .observeValues { [weak self] styleType in
        _ = self?.pledgeButton
          ?|> styleType.style
      }
  }

  internal func configure(with value: (project: Project, reward: Either<Reward, Backing>)) {
    self.viewModel.inputs.configureWith(project: value.project, rewardOrBacking: value.reward)
    self.rewardCardView.configure(with: value)
  }

  // MARK: - Functions

  private func configureViews() {
    _ = (self.rewardCardView, self)
      |> ksr_addSubviewToParent()

    _ = (self.pledgeButtonLayoutGuide, self)
      |> ksr_addLayoutGuideToView()

    _ = (self.pledgeButton, self)
      |> ksr_addSubviewToParent()

    self.pledgeButton.addTarget(self, action: #selector(self.pledgeButtonTapped), for: .touchUpInside)
  }

  public func setupConstraints() {
    self.pledgeButtonHiddenConstraints = self.hiddenPledgeHiddenConstraints()
    self.pledgeButtonShownConstraints = self.shownPledgeButtonConstraints()

    NSLayoutConstraint.activate(self.pledgeButtonShownConstraints)
  }

  private func hiddenPledgeHiddenConstraints() -> [NSLayoutConstraint] {
    let containerMargins = self.layoutMarginsGuide

    let rewardCardViewConstraints = [
      self.rewardCardView.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
      self.rewardCardView.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
      self.rewardCardView.topAnchor.constraint(equalTo: containerMargins.topAnchor),
      self.rewardCardView.bottomAnchor.constraint(equalTo: containerMargins.bottomAnchor)
    ]

    return rewardCardViewConstraints
  }

  private func shownPledgeButtonConstraints() -> [NSLayoutConstraint] {
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
      self.pledgeButtonLayoutGuide.topAnchor.constraint(
        equalTo: self.rewardCardView.bottomAnchor, constant: Styles.grid(3)
      ),
      self.pledgeButtonLayoutGuide.heightAnchor.constraint(equalTo: self.pledgeButton.heightAnchor)
    ]

    let constraints = [
      [pledgeButtonTopConstraint],
      rewardCardViewConstraints,
      pledgeButtonLayoutGuideConstraints
    ]
    .flatMap { $0 }

    return constraints
  }

  private func addBottomViewsMarginConstraints(with layoutMarginsGuide: UILayoutGuide) {
    NSLayoutConstraint.deactivate(self.pledgeButtonMarginConstraints ?? [])
    let minTouchSize = Styles.minTouchSize.height

    let pledgeButtonMarginConstraints = [
      self.pledgeButton.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
      self.pledgeButton.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
      self.pledgeButton.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
      self.pledgeButton.heightAnchor.constraint(
        greaterThanOrEqualToConstant: minTouchSize
      )
    ]

    NSLayoutConstraint.activate(pledgeButtonMarginConstraints)

    self.pledgeButtonMarginConstraints = pledgeButtonMarginConstraints
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
