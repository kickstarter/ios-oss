import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol RewardCardViewDelegate: AnyObject {
  func rewardCardView(_ rewardCardView: RewardCardView, didTapWithRewardId rewardId: Int)
}

public final class RewardCardView: UIView {
  // MARK: - Properties

  weak var delegate: RewardCardViewDelegate?
  private let viewModel: RewardCardViewModelType = RewardCardViewModel()

  private let baseStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let descriptionLabel = UILabel(frame: .zero)
  private let descriptionStackView = UIStackView(frame: .zero)
  private let estimatedDeliveryStackView = UIStackView(frame: .zero)
  private let estimatedDeliveryTitleLabel = UILabel(frame: .zero)
  private let estimatedDeliveryDateLabel = UILabel(frame: .zero)
  private let includedItemsStackView = UIStackView(frame: .zero)
  private let includedItemsTitleLabel = UILabel(frame: .zero)
  private let minimumPriceConversionLabel = UILabel(frame: .zero)
  private let minimumPriceLabel = UILabel(frame: .zero)
  private let pillsView: PillsView = PillsView(frame: .zero)
  private var pillsViewHeightConstraint: NSLayoutConstraint?
  private let priceStackView = UIStackView(frame: .zero)
  private let rewardLocationStackView = UIStackView(frame: .zero)
  private let rewardLocationTitleLabel = UILabel(frame: .zero)
  private let rewardLocationPickupLabel = UILabel(frame: .zero)
  private let rewardTitleLabel = UILabel(frame: .zero)
  private let titleStackView = UIStackView(frame: .zero)

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
      self.baseStackView,
      self.priceStackView,
      self.descriptionStackView,
      self.includedItemsStackView,
      self.estimatedDeliveryStackView,
      self.rewardLocationStackView
    ]
      ||> { stackView in
        stackView
          |> sectionStackViewStyle
      }

    _ = self.baseStackView
      |> baseStackViewStyle

    _ = self.priceStackView
      |> priceStackViewStyle

    _ = self.includedItemsStackView
      |> includedItemsStackViewStyle

    _ = self.includedItemsTitleLabel
      |> baseRewardLabelStyle
      |> sectionTitleLabelStyle

    _ = self.includedItemsTitleLabel
      |> \.text %~ { _ in Strings.project_view_pledge_includes() }
      |> \.textColor .~ UIColor.ksr_support_400

    _ = self.includedItemsStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      ||> baseRewardLabelStyle
      ||> sectionBodyLabelStyle

    _ = self.descriptionLabel
      |> baseRewardLabelStyle
      |> sectionBodyLabelStyle

    _ = self.estimatedDeliveryStackView
      |> includedItemsStackViewStyle

    _ = self.estimatedDeliveryTitleLabel
      |> baseRewardLabelStyle
      |> sectionTitleLabelStyle

    _ = self.estimatedDeliveryTitleLabel
      |> \.text %~ { _ in Strings.Estimated_delivery() }
      |> \.textColor .~ UIColor.ksr_support_400

    _ = self.estimatedDeliveryDateLabel
      |> baseRewardLabelStyle
      |> sectionBodyLabelStyle

    _ = self.estimatedDeliveryStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      ||> baseRewardLabelStyle
      ||> sectionBodyLabelStyle

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

    _ = self.rewardTitleLabel
      |> baseRewardLabelStyle
      |> rewardTitleLabelStyle

    _ = self.minimumPriceLabel
      |> baseRewardLabelStyle
      |> minimumPriceLabelStyle

    _ = self.minimumPriceConversionLabel
      |> baseRewardLabelStyle
      |> minimumPriceConversionLabelStyle

    _ = self.pillsView
      |> \.backgroundColor .~ self.backgroundColor
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.minimumPriceConversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.minimumPriceConversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.estimatedDeliveryStackView.rac.hidden = self.viewModel.outputs.estimatedDeliveryStackViewHidden
    self.estimatedDeliveryDateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryDateLabelText
    self.rewardLocationStackView.rac.hidden = self.viewModel.outputs.rewardLocationStackViewHidden
    self.rewardLocationPickupLabel.rac.text = self.viewModel.outputs.rewardLocationPickupLabelText
    self.includedItemsStackView.rac.hidden = self.viewModel.outputs.includedItemsStackViewHidden
    self.minimumPriceLabel.rac.text = self.viewModel.outputs.rewardMinimumLabelText
    self.pillsView.rac.hidden = self.viewModel.outputs.pillCollectionViewHidden
    self.rewardTitleLabel.rac.hidden = self.viewModel.outputs.rewardTitleLabelHidden
    self.rewardTitleLabel.rac.attributedText = self.viewModel.outputs.rewardTitleLabelAttributedText

    self.viewModel.outputs.items
      .observeForUI()
      .observeValues { [weak self] in self?.load(items: $0) }

    self.viewModel.outputs.rewardSelected
      .observeForUI()
      .observeValues { [weak self] rewardId in
        guard let self = self else { return }

        self.delegate?.rewardCardView(self, didTapWithRewardId: rewardId)
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
    _ = (self.baseStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    let baseSubviews = [
      self.titleStackView,
      self.rewardTitleLabel,
      self.descriptionStackView,
      self.includedItemsStackView,
      self.estimatedDeliveryStackView,
      self.rewardLocationStackView,
      self.pillsView
    ]

    _ = (baseSubviews, self.baseStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.minimumPriceLabel, self.minimumPriceConversionLabel], self.priceStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.includedItemsTitleLabel], self.includedItemsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.estimatedDeliveryTitleLabel, self.estimatedDeliveryDateLabel], self.estimatedDeliveryStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.rewardLocationTitleLabel, self.rewardLocationPickupLabel], self.rewardLocationStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.descriptionLabel], self.descriptionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.priceStackView], self.titleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.rewardCardTapped))
    self.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupConstraints() {
    let pillsViewHeightConstraint = self.pillsView.heightAnchor.constraint(equalToConstant: 0)
    self.pillsViewHeightConstraint = pillsViewHeightConstraint

    NSLayoutConstraint.activate([pillsViewHeightConstraint])
  }

  private func configurePillsView(_ pills: [RewardCardPillData]) {
    let pillData = pills.map { rewardCardPillData -> PillData in
      PillData(
        backgroundColor: rewardCardPillData.backgroundColor,
        font: UIFont.ksr_footnote().bolded,
        margins: UIEdgeInsets(topBottom: Styles.gridHalf(2), leftRight: Styles.gridHalf(3)),
        text: rewardCardPillData.text,
        textColor: rewardCardPillData.textColor,
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

  fileprivate func load(items: [String]) {
    _ = self.includedItemsStackView.subviews
      ||> { $0.removeFromSuperview() }

    let includedItemViews = items.map { item -> UIView in
      let label = UILabel()
        |> baseRewardLabelStyle
        |> sectionBodyLabelStyle
        |> \.text .~ item

      return label
    }

    let separatedItemViews = includedItemViews.dropLast().map { view -> [UIView] in
      let separator = UIView()
        |> separatorStyle
      separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

      return [view, separator]
    }
    .flatMap { $0 }

    let allItemViews = [self.includedItemsTitleLabel]
      + separatedItemViews
      + [includedItemViews.last].compact()

    _ = (allItemViews, self.includedItemsStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - Configuration

  internal func configure(with data: RewardCardViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: - Selectors

  @objc func rewardCardTapped() {
    self.viewModel.inputs.rewardCardTapped()
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

private let minimumPriceLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_create_700
    |> \.font .~ UIFont.ksr_title3().bolded
}

private let minimumPriceConversionLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_create_700
    |> \.font .~ UIFont.ksr_caption1().bolded
}

private let priceStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.gridHalf(1)
}

private let rewardTitleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_700
    |> \.font .~ UIFont.ksr_title2().bolded
}

private let sectionStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(1)
}

private let sectionTitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ .ksr_headline()
}

private let sectionBodyLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_700
    |> \.font .~ UIFont.ksr_body()
}

// MARK: - UICollectionViewDelegate

extension RewardCardView: UICollectionViewDelegate {
  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    guard let pillCell = cell as? PillCell else { return }

    _ = pillCell.label
      |> \.preferredMaxLayoutWidth .~ collectionView.bounds.width
  }
}
