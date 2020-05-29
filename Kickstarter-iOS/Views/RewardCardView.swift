import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift

protocol RewardCardViewDelegate: AnyObject {
  func rewardCardView(_ rewardCardView: RewardCardView, didTapWithRewardId rewardId: Int)
}

public final class RewardCardView: UIView {
  // MARK: - Properties

  weak var delegate: RewardCardViewDelegate?
  private let pillDataSource = PillCollectionViewDataSource()
  private let viewModel: RewardCardViewModelType = RewardCardViewModel()

  private let baseStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let descriptionLabel = UILabel(frame: .zero)
  private let descriptionStackView = UIStackView(frame: .zero)
  private let estimatedDeliveryDateLabel = UILabel(frame: .zero)
  private let includedItemsStackView = UIStackView(frame: .zero)
  private let includedItemsTitleLabel = UILabel(frame: .zero)
  private let minimumPriceConversionLabel = UILabel(frame: .zero)
  private let minimumPriceLabel = UILabel(frame: .zero)
  private let priceStackView = UIStackView(frame: .zero)

  private lazy var pillCollectionView: UICollectionView = {
    UICollectionView(
      frame: .zero,
      collectionViewLayout: PillLayout(
        minimumInteritemSpacing: Styles.grid(1),
        minimumLineSpacing: Styles.grid(1),
        sectionInset: UIEdgeInsets(topBottom: Styles.grid(1))
      )
    )
      |> \.contentInsetAdjustmentBehavior .~ UIScrollView.ContentInsetAdjustmentBehavior.always
      |> \.dataSource .~ self.pillDataSource
      |> \.delegate .~ self
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pillCollectionViewHeightConstraint: NSLayoutConstraint = {
    self.pillCollectionView.heightAnchor.constraint(equalToConstant: 0)
      |> \.priority .~ .defaultHigh
  }()

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

    self.updateCollectionViewConstraints()
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutWhiteBackgroundStyle

    _ = [
      self.baseStackView,
      self.priceStackView,
      self.descriptionStackView,
      self.includedItemsStackView
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
      |> \.textColor .~ UIColor.ksr_text_dark_grey_500

    _ = self.includedItemsStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      ||> baseRewardLabelStyle
      ||> sectionBodyLabelStyle

    _ = self.descriptionLabel
      |> baseRewardLabelStyle
      |> sectionBodyLabelStyle

    _ = self.estimatedDeliveryDateLabel
      |> baseRewardLabelStyle
      |> sectionBodyLabelStyle

    _ = self.rewardTitleLabel
      |> baseRewardLabelStyle
      |> rewardTitleLabelStyle

    _ = self.minimumPriceLabel
      |> baseRewardLabelStyle
      |> minimumPriceLabelStyle

    _ = self.minimumPriceConversionLabel
      |> baseRewardLabelStyle
      |> minimumPriceConversionLabelStyle

    _ = (self.pillCollectionView, self.backgroundColor)
      |> pillCollectionViewStyle

    _ = self.titleStackView
      |> titleStackViewStyle
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.minimumPriceConversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.minimumPriceConversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.estimatedDeliveryDateLabel.rac.hidden = self.viewModel.outputs.estimatedDeliveryDateLabelHidden
    self.estimatedDeliveryDateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryDateLabelText
    self.includedItemsStackView.rac.hidden = self.viewModel.outputs.includedItemsStackViewHidden
    self.minimumPriceLabel.rac.text = self.viewModel.outputs.rewardMinimumLabelText
    self.pillCollectionView.rac.hidden = self.viewModel.outputs.pillCollectionViewHidden
    self.rewardTitleLabel.rac.hidden = self.viewModel.outputs.rewardTitleLabelHidden
    self.rewardTitleLabel.rac.text = self.viewModel.outputs.rewardTitleLabelText

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
        self?.pillDataSource.load(values)
        self?.pillCollectionView.reloadData()
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
      self.estimatedDeliveryDateLabel,
      self.pillCollectionView
    ]

    _ = (baseSubviews, self.baseStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.minimumPriceLabel, self.minimumPriceConversionLabel], self.priceStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.includedItemsTitleLabel], self.includedItemsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.descriptionLabel], self.descriptionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.priceStackView], self.titleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.pillCollectionView.register(PillCell.self)

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.rewardCardTapped))
    self.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupConstraints() {
    let pillCollectionViewConstraints = [
      self.pillCollectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.pillCollectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.pillCollectionViewHeightConstraint
    ]

    NSLayoutConstraint.activate(pillCollectionViewConstraints)
  }

  private func updateCollectionViewConstraints() {
    self.pillCollectionView.layoutIfNeeded()

    self.pillCollectionViewHeightConstraint.constant = self.pillCollectionView.contentSize.height
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

  internal func configure(with value: (Project, Either<Reward, Backing>)) {
    self.viewModel.inputs.configureWith(project: value.0, rewardOrBacking: value.1)
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
    |> \.textColor .~ .ksr_green_500
    |> \.font .~ UIFont.ksr_title3().bolded
}

private let minimumPriceConversionLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_green_500
    |> \.font .~ UIFont.ksr_caption1().bolded
}

private let pillCollectionViewStyle: (UICollectionView, UIColor?)
  -> UICollectionView = { collectionView, backgroundColor in
    collectionView
      |> \.backgroundColor .~ backgroundColor
  }

private let priceStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.gridHalf(1)
}

private let rewardTitleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ UIFont.ksr_title2().bolded
}

private let sectionStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.alignment .~ .fill
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(1)
}

private let sectionTitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ .ksr_headline()
}

private let sectionBodyLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ UIFont.ksr_body()
}

private let titleStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
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
