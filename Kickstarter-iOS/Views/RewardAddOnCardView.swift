import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift

protocol RewardAddOnCardViewDelegate: AnyObject {
  func rewardAddOnCardView(_ rewardAddOnCardView: RewardAddOnCardView, didTapWithRewardId rewardId: Int)
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

  private let amountConversionLabel = UILabel(frame: .zero)
  private let amountLabel = UILabel(frame: .zero)
  private let descriptionLabel = UILabel(frame: .zero)
  private let includedItemsSeparator: UIView = UIView(frame: .zero)
  private let includedItemsStackView = UIStackView(frame: .zero)
  private let includedItemsTitleLabel = UILabel(frame: .zero)
  private let includedItemsLabel = UILabel(frame: .zero)
  private let pillsView: PillsView = PillsView(frame: .zero)
  private var pillsViewHeightConstraint: NSLayoutConstraint?

  private let rewardTitleLabel = UILabel(frame: .zero)
  private let titleAmountStackView = UIStackView(frame: .zero)

  override init(frame: CGRect) {
    super.init(frame: frame)

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

    _ = [
      self.rootStackView,
      self.titleAmountStackView,
      self.includedItemsStackView
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
      |> \.textColor .~ UIColor.ksr_text_dark_grey_500

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
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.amountConversionLabel.rac.hidden = self.viewModel.outputs.amountConversionLabelHidden
    self.amountConversionLabel.rac.text = self.viewModel.outputs.amountConversionLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.includedItemsStackView.rac.hidden = self.viewModel.outputs.includedItemsStackViewHidden
    self.includedItemsLabel.rac.attributedText = self.viewModel.outputs.includedItemsLabelAttributedText
    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountLabelAttributedText
    self.pillsView.rac.hidden = self.viewModel.outputs.pillsViewHidden
    self.rewardTitleLabel.rac.text = self.viewModel.outputs.rewardTitleLabelText

    self.viewModel.outputs.rewardSelected
      .observeForUI()
      .observeValues { [weak self] rewardId in
        guard let self = self else { return }

        self.delegate?.rewardAddOnCardView(self, didTapWithRewardId: rewardId)
      }

    self.viewModel.outputs.cardUserInteractionIsEnabled
      .observeForUI()
      .observeValues { [weak self] isUserInteractionEnabled in
        _ = self
          ?|> \.isUserInteractionEnabled .~ isUserInteractionEnabled
      }

    self.viewModel.outputs.reloadPills
      .observeForUI()
      .observeValues { [weak self] values in
        self?.configurePillsView(values)
      }
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
      self.pillsView
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

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.rewardCardTapped))
    self.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupConstraints() {
    let pillsViewHeightConstraint = self.pillsView.heightAnchor.constraint(equalToConstant: 0)
    self.pillsViewHeightConstraint = pillsViewHeightConstraint

    let pillCollectionViewConstraints = [
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
        textColor: .ksr_dark_grey_500
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

  // MARK: - Selectors

  @objc func rewardCardTapped() {
    self.viewModel.inputs.rewardAddOnCardTapped()
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
    |> \.textColor .~ .ksr_green_500
    |> \.font .~ UIFont.ksr_title3().bolded
}

private let convertedAmountLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_dark_grey_500
    |> \.font .~ UIFont.ksr_footnote().weighted(.medium)
}

private let titleAmountStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.gridHalf(1)
}

private let rewardTitleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ UIFont.ksr_title3().bolded
}

private let sectionStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(1)
}

private let descriptionLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ UIFont.ksr_body()
}
