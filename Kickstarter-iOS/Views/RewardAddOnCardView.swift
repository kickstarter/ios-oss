import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol RewardAddOnCardViewDelegate: AnyObject {
  func rewardAddOnCardView(
    _ cardView: RewardAddOnCardView,
    didSelectQuantity quantity: Int,
    rewardId: Int
  )
}

public final class RewardAddOnCardView: UIView {
  // MARK: - Properties

  weak var delegate: RewardAddOnCardViewDelegate?
  private let viewModel: RewardAddOnCardViewModelType = RewardAddOnCardViewModel()

  private let rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.insetsLayoutMarginsFromSafeArea .~ false
  }()

  private let addButton = UIButton(type: .custom)
  private let amountConversionLabel = UILabel(frame: .zero)
  private let amountLabel = UILabel(frame: .zero)
  private let descriptionLabel = UILabel(frame: .zero)
  private let includedItemsSeparator: UIView = UIView(frame: .zero)
  private let includedItemsStackView = UIStackView(frame: .zero)
  private let includedItemsTitleLabel = UILabel(frame: .zero)
  private let includedItemsLabel = UILabel(frame: .zero)
  private let quantityLabel = UILabel(frame: .zero)
  private let quantityLabelContainer = UIView(frame: .zero)
  private let pillsView: PillsView = PillsView(frame: .zero)
  private var pillsViewHeightConstraint: NSLayoutConstraint?
  private let stepper: UIStepper = UIStepper(frame: .zero)
  private let stepperStackView = UIStackView(frame: .zero)
  private let rewardLocationStackView = UIStackView(frame: .zero)
  private let rewardLocationTitleLabel = UILabel(frame: .zero)
  private let rewardLocationPickupLabel = UILabel(frame: .zero)
  private let rewardTitleLabel = UILabel(frame: .zero)
  private let titleAmountStackView = UIStackView(frame: .zero)

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addButton.addTarget(
      self,
      action: #selector(RewardAddOnCardView.addButtonTapped),
      for: .touchUpInside
    )

    self.stepper.addTarget(
      self,
      action: #selector(RewardAddOnCardView.stepperValueChanged(_:)),
      for: .valueChanged
    )

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    self.pillsViewHeightConstraint?.constant = self.pillsView.intrinsicContentSize.height
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutWhiteBackgroundStyle

    _ = self.addButton
      |> UIButton.lens.title(for: .normal) .~ Strings.Add()
      |> blackButtonStyle

    _ = [
      self.rootStackView,
      self.titleAmountStackView,
      self.includedItemsStackView,
      self.rewardLocationStackView
    ]
      ||> { stackView in
        stackView
          |> sectionStackViewStyle
      }

    _ = self.rootStackView
      |> baseStackViewStyle

    _ = self.titleAmountStackView
      |> titleAmountStackViewStyle

    _ = self.includedItemsSeparator
      |> separatorStyle

    _ = self.includedItemsStackView
      |> includedItemsStackViewStyle

    _ = self.includedItemsTitleLabel
      |> baseRewardLabelStyle
      |> \.font .~ UIFont.ksr_callout().weighted(.semibold)
      |> \.text %~ { _ in Strings.project_view_pledge_includes() }
      |> \.textColor .~ UIColor.ksr_support_400

    _ = self.includedItemsLabel
      |> baseRewardLabelStyle
      |> \.font .~ .ksr_callout()

    _ = self.descriptionLabel
      |> baseRewardLabelStyle
      |> descriptionLabelStyle

    _ = self.rewardTitleLabel
      |> baseRewardLabelStyle
      |> rewardTitleLabelStyle

    _ = self.amountLabel
      |> baseRewardLabelStyle
      |> amountLabelStyle

    _ = self.amountConversionLabel
      |> baseRewardLabelStyle
      |> convertedAmountLabelStyle

    _ = self.quantityLabelContainer
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      |> \.layer.borderColor .~ UIColor.ksr_support_300.cgColor
      |> \.layer.borderWidth .~ 1
      |> checkoutRoundedCornersStyle

    _ = self.quantityLabel
      |> \.font .~ UIFont.ksr_headline().monospaced

    _ = self.stepper
      |> checkoutStepperStyle
      |> UIStepper.lens.decrementImage(for: .normal) .~ image(named: "stepper-decrement-normal-grey")
      |> UIStepper.lens.incrementImage(for: .normal) .~ image(named: "stepper-increment-normal-grey")

    _ = self.stepperStackView
      |> \.alignment .~ .center

    _ = ([self.rewardLocationTitleLabel, self.rewardLocationPickupLabel], self.rewardLocationStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = self.rewardLocationStackView
      |> includedItemsStackViewStyle

    _ = self.rewardLocationTitleLabel
      |> baseRewardLabelStyle
      |> sectionTitleLabelStyle

    _ = self.rewardLocationTitleLabel
      |> \.text %~ { _ in Strings.Reward_location() }
      |> \.textColor .~ UIColor.ksr_support_400

    _ = self.rewardLocationPickupLabel
      |> baseRewardLabelStyle
      |> sectionBodyLabelStyle

    _ = self.rewardLocationStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      ||> baseRewardLabelStyle
      ||> sectionBodyLabelStyle
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.addButton.rac.hidden = self.viewModel.outputs.addButtonHidden
    self.amountConversionLabel.rac.hidden = self.viewModel.outputs.amountConversionLabelHidden
    self.amountConversionLabel.rac.text = self.viewModel.outputs.amountConversionLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.includedItemsStackView.rac.hidden = self.viewModel.outputs.includedItemsStackViewHidden
    self.includedItemsLabel.rac.attributedText = self.viewModel.outputs.includedItemsLabelAttributedText
    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountLabelAttributedText
    self.pillsView.rac.hidden = self.viewModel.outputs.pillsViewHidden
    self.quantityLabel.rac.text = self.viewModel.outputs.quantityLabelText
    self.rewardLocationStackView.rac.hidden = self.viewModel.outputs.rewardLocationStackViewHidden
    self.rewardLocationPickupLabel.rac.text = self.viewModel.outputs.rewardLocationPickupLabelText
    self.rewardTitleLabel.rac.text = self.viewModel.outputs.rewardTitleLabelText
    self.stepperStackView.rac.hidden = self.viewModel.outputs.stepperStackViewHidden
    self.stepper.rac.maximumValue = self.viewModel.outputs.stepperMaxValue
    self.stepper.rac.value = self.viewModel.outputs.stepperValue

    self.viewModel.outputs.notifiyDelegateDidSelectQuantity
      .observeForUI()
      .observeValues { [weak self] quantity, rewardId in
        guard let self = self else { return }
        self.delegate?.rewardAddOnCardView(self, didSelectQuantity: quantity, rewardId: rewardId)
      }

    self.viewModel.outputs.reloadPills
      .observeForUI()
      .observeValues { [weak self] values in
        self?.configurePillsView(values)
      }

    self.viewModel.outputs.generateSelectionFeedback
      .observeForUI()
      .observeValues { generateSelectionFeedback() }

    self.viewModel.outputs.generateNotificationWarningFeedback
      .observeForUI()
      .observeValues { generateNotificationWarningFeedback() }
  }

  // MARK: - Private Helpers

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    let rootSubviews = [
      self.rewardTitleLabel,
      self.titleAmountStackView,
      self.descriptionLabel,
      self.includedItemsStackView,
      self.rewardLocationStackView,
      self.pillsView,
      self.addButton,
      self.stepperStackView
    ]

    _ = (rootSubviews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let titleAmountViews = [self.rewardTitleLabel, self.amountLabel, self.amountConversionLabel]

    _ = (titleAmountViews, self.titleAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let includedItemsViews = [
      self.includedItemsSeparator,
      self.includedItemsTitleLabel,
      self.includedItemsLabel
    ]

    _ = (includedItemsViews, self.includedItemsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.quantityLabel, self.quantityLabelContainer)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.stepper, UIView(), self.quantityLabelContainer], self.stepperStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    let pillsViewHeightConstraint = self.pillsView.heightAnchor.constraint(equalToConstant: 0)
    self.pillsViewHeightConstraint = pillsViewHeightConstraint

    let pillCollectionViewConstraints = [
      self.addButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.stepperStackView.heightAnchor.constraint(equalTo: self.addButton.heightAnchor),
      self.includedItemsSeparator.heightAnchor.constraint(equalToConstant: 1),
      pillsViewHeightConstraint
    ]

    NSLayoutConstraint.activate(pillCollectionViewConstraints)
  }

  private func configurePillsView(_ pills: [String]) {
    let pillData = pills.map { text -> PillData in
      PillData(
        backgroundColor: UIColor.ksr_celebrate_100,
        font: UIFont.ksr_footnote().bolded,
        margins: UIEdgeInsets(topBottom: Styles.gridHalf(2), leftRight: Styles.gridHalf(3)),
        text: text,
        textColor: .ksr_support_400,
        imageName: nil
      )
    }

    let data = PillsViewData(
      interimLineSpacing: Styles.grid(1),
      interimPillSpacing: Styles.grid(1),
      margins: .zero,
      pills: pillData
    )

    self.pillsView.configure(with: data)
  }

  // MARK: - Configuration

  internal func configure(with data: RewardAddOnCardViewData) {
    self.viewModel.inputs.configure(with: data)

    self.layoutIfNeeded()
  }

  // MARK: - Actions

  @objc func addButtonTapped() {
    self.viewModel.inputs.addButtonTapped()
  }

  @objc func stepperValueChanged(_ stepper: UIStepper) {
    self.viewModel.inputs.stepperValueChanged(stepper.value)
  }
}

// MARK: - Styles

private let baseRewardLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 0
    |> \.textAlignment .~ .left
    |> \.lineBreakMode .~ .byWordWrapping
}

private let baseStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(3)
}

private let includedItemsStackViewStyle: StackViewStyle = { stackView in
  stackView |> \.spacing .~ Styles.grid(2)
}

private let amountLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_create_700
    |> \.font .~ UIFont.ksr_title3().bolded
}

private let convertedAmountLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_400
    |> \.font .~ UIFont.ksr_footnote().weighted(.medium)
}

private let descriptionLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_700
    |> \.font .~ UIFont.ksr_body()
}

private let titleAmountStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.gridHalf(1)
}

private let rewardTitleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_700
    |> \.font .~ UIFont.ksr_title3().bolded
}

private let sectionStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(1)
}

private let sectionBodyLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_700
    |> \.font .~ UIFont.ksr_body()
}

private let sectionTitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ .ksr_headline()
}
