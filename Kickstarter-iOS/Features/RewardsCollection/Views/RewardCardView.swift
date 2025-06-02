import KsApi
import Library
import ReactiveSwift
import UIKit

protocol RewardCardViewDelegate: AnyObject {
  func rewardCardView(_ rewardCardView: RewardCardView, didTapWithRewardId rewardId: Int)
}

public final class RewardCardView: UIView {
  // MARK: - Properties

  weak var delegate: RewardCardViewDelegate?
  private let viewModel: RewardCardViewModelType = RewardCardViewModel()

  private let rootStackView: UIStackView = UIStackView(frame: .zero)

  private let detailsStackView: UIStackView = UIStackView(frame: .zero)

  private let rewardImageView = UIImageView(frame: .zero)
  private let secretRewardBadgeView = BadgeView(frame: .zero)
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

  private let estimatedShippingStackView = UIStackView(frame: .zero)
  private let estimatedShippingTitleLabel = UILabel(frame: .zero)
  private let estimatedShippingLabel = UILabel(frame: .zero)

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    self.pillsViewHeightConstraint?.constant = self.pillsView.intrinsicContentSize.height
  }

  public override func bindStyles() {
    super.bindStyles()

    let stackViews = [
      self.detailsStackView,
      self.priceStackView,
      self.descriptionStackView,
      self.includedItemsStackView,
      self.estimatedShippingStackView,
      self.estimatedDeliveryStackView,
      self.rewardLocationStackView
    ]

    stackViews.forEach(applySectionStackViewStyle)
    applyRootStackViewStyle(self.rootStackView)
    applyDetailsStackViewStyle(self.detailsStackView)
    applyPriceStackViewStyle(self.priceStackView)
    applyIncludedItemsStackViewStyle(self.includedItemsStackView)
    applyIncludedItemsTitleLabelStyle(self.includedItemsTitleLabel)

    self.includedItemsStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      .forEach { label in
        applyBaseRewardLabelStyle(label)
        applySectionBodyLabelStyle(label)
      }

    applyBaseRewardLabelStyle(self.descriptionLabel)
    applySectionBodyLabelStyle(self.descriptionLabel)
    applyIncludedItemsStackViewStyle(self.estimatedDeliveryStackView)
    applyEstimatedDeliveryTitleLabelStyle(self.estimatedDeliveryTitleLabel)
    applyBaseRewardLabelStyle(self.estimatedDeliveryDateLabel)
    applySectionBodyLabelStyle(self.estimatedDeliveryDateLabel)

    self.estimatedDeliveryStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      .forEach { label in
        applyBaseRewardLabelStyle(label)
        applySectionBodyLabelStyle(label)
      }

    applyIncludedItemsStackViewStyle(self.estimatedShippingStackView)
    applyEstimatedShippingTitleLabelStyle(self.estimatedShippingTitleLabel)
    applyBaseRewardLabelStyle(self.estimatedShippingLabel)
    applySectionBodyLabelStyle(self.estimatedShippingLabel)

    self.estimatedShippingStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      .forEach { label in
        applyBaseRewardLabelStyle(label)
        applySectionBodyLabelStyle(label)
      }

    applyIncludedItemsStackViewStyle(self.rewardLocationStackView)
    applyRewardLocationTitleLabelStyle(self.rewardLocationTitleLabel)
    applyBaseRewardLabelStyle(self.rewardLocationPickupLabel)
    applySectionBodyLabelStyle(self.rewardLocationPickupLabel)

    self.rewardLocationStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      .forEach { label in
        applyBaseRewardLabelStyle(label)
        applySectionBodyLabelStyle(label)
      }

    applyBaseRewardLabelStyle(self.rewardTitleLabel)
    applyRewardTitleLabelStyle(self.rewardTitleLabel)
    applyBaseRewardLabelStyle(self.minimumPriceLabel)
    applyMinimumPriceLabelStyle(self.minimumPriceLabel)
    applyBaseRewardLabelStyle(self.minimumPriceConversionLabel)
    applyMinimumPriceConversionLabelStyle(self.minimumPriceConversionLabel)
    applyPillsViewStyle(self.pillsView)
    applyRewardImageViewStyle(self.rewardImageView)

    let badgeStyle = BadgeStyle.custom(
      foregroundColor: Colors.Text.Accent.Green.bolder.uiColor(),
      backgroundColor: Colors.Background.Accent.Green.subtle.uiColor()
    )

    self.secretRewardBadgeView.configure(
      with: Strings.Secret_reward(),
      image: Library.image(named: "Locked"),
      style: badgeStyle
    )
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.minimumPriceConversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.minimumPriceConversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.estimatedShippingStackView.rac.hidden = self.viewModel.outputs.estimatedShippingStackViewHidden
    self.estimatedDeliveryStackView.rac.hidden = self.viewModel.outputs.estimatedDeliveryStackViewHidden
    self.estimatedDeliveryDateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryDateLabelText
    self.rewardLocationStackView.rac.hidden = self.viewModel.outputs.rewardLocationStackViewHidden
    self.rewardLocationPickupLabel.rac.text = self.viewModel.outputs.rewardLocationPickupLabelText
    self.includedItemsStackView.rac.hidden = self.viewModel.outputs.includedItemsStackViewHidden
    self.minimumPriceLabel.rac.text = self.viewModel.outputs.rewardMinimumLabelText
    self.pillsView.rac.hidden = self.viewModel.outputs.pillCollectionViewHidden
    self.rewardTitleLabel.rac.hidden = self.viewModel.outputs.rewardTitleLabelHidden
    self.rewardTitleLabel.rac.attributedText = self.viewModel.outputs.rewardTitleLabelAttributedText
    self.rewardImageView.rac.hidden = self.viewModel.outputs.rewardImageHidden

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
        self?.isUserInteractionEnabled = isUserInteractionEnabled
      }

    self.viewModel.outputs.reloadPills
      .observeForUI()
      .observeValues { [weak self] values in
        self?.configurePillsView(values)
      }

    self.viewModel.outputs.estimatedShippingLabelText
      .observeForUI()
      .observeValues { [weak self] text in
        guard let labelText = text else { return }

        self?.estimatedShippingLabel.text = labelText
      }

    self.viewModel.outputs.rewardImage
      .observeForUI()
      .on(event: { [weak rewardImageView] _ in
        rewardImageView?.af.cancelImageRequest()
        rewardImageView?.image = nil
      })
      .observeValues { [weak rewardImageView] image in
        rewardImageView?.accessibilityLabel = image.altText

        guard let url = image.url, let imageURL = URL(string: url) else { return }
        rewardImageView?.ksr_setImageWithURL(imageURL)
      }

    self.secretRewardBadgeView.rac.hidden = self.viewModel.outputs.secretRewardBadgeHidden
  }

  // MARK: - Private Helpers

  private func configureViews() {
    self.addSubview(self.rootStackView)
    self.rootStackView.constrainViewToEdges(in: self)
    self.rootStackView.addArrangedSubviews(self.rewardImageView, self.detailsStackView)

    self.addSubview(self.secretRewardBadgeView)

    self.rewardImageView.isHidden = true

    self.detailsStackView.addArrangedSubviews(
      self.titleStackView,
      self.rewardTitleLabel,
      self.descriptionStackView,
      self.includedItemsStackView,
      self.estimatedShippingStackView,
      self.estimatedDeliveryStackView,
      self.rewardLocationStackView,
      self.pillsView
    )

    self.priceStackView.addArrangedSubviews(
      self.minimumPriceLabel,
      self.minimumPriceConversionLabel
    )

    self.includedItemsStackView.addArrangedSubview(self.includedItemsTitleLabel)

    self.estimatedShippingStackView.addArrangedSubviews(
      self.estimatedShippingTitleLabel,
      self.estimatedShippingLabel
    )

    self.estimatedDeliveryStackView.addArrangedSubviews(
      self.estimatedDeliveryTitleLabel,
      self.estimatedDeliveryDateLabel
    )

    self.rewardLocationStackView.addArrangedSubviews(
      self.rewardLocationTitleLabel,
      self.rewardLocationPickupLabel
    )

    self.descriptionStackView.addArrangedSubview(self.descriptionLabel)
    self.titleStackView.addArrangedSubview(self.priceStackView)

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.rewardCardTapped))
    self.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupConstraints() {
    self.detailsStackView.translatesAutoresizingMaskIntoConstraints = false

    let pillsViewHeightConstraint = self.pillsView.heightAnchor.constraint(equalToConstant: 0)
    self.pillsViewHeightConstraint = pillsViewHeightConstraint

    NSLayoutConstraint.activate([pillsViewHeightConstraint])

    let aspectRatio: CGFloat = 1.5
    let constratint = self.rewardImageView.heightAnchor.constraint(
      equalTo: self.rewardImageView.widthAnchor,
      multiplier: 1.0 / aspectRatio
    )
    constratint.priority = UILayoutPriority(rawValue: 999)
    constratint.isActive = true

    self.secretRewardBadgeView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      self.secretRewardBadgeView.bottomAnchor.constraint(
        equalTo: self.detailsStackView.topAnchor,
        constant: Styles.grid(2)
      ),
      self.secretRewardBadgeView.leadingAnchor.constraint(
        equalTo: self.leadingAnchor,
        constant: Styles.grid(3)
      )
    ])
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
    self.includedItemsStackView.subviews
      .forEach { $0.removeFromSuperview() }

    let includedItemViews = items.map { item -> UIView in
      let label = UILabel()
      applyBaseRewardLabelStyle(label)
      applySectionBodyLabelStyle(label)
      label.text = item
      return label
    }

    let separatedItemViews = includedItemViews.dropLast().map { view -> [UIView] in
      let separator = UIView()
      _ = separatorStyle(separator)
      separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

      return [view, separator]
    }
    .flatMap { $0 }

    let allItemViews = [self.includedItemsTitleLabel]
      + separatedItemViews
      + [includedItemViews.last].compact()

    self.includedItemsStackView.addArrangedSubviews(allItemViews)
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

private func applyBaseRewardLabelStyle(_ label: UILabel) {
  label.numberOfLines = 0
  label.textAlignment = .left
  label.lineBreakMode = .byWordWrapping
}

private func applySectionTitleLabelStyle(_ label: UILabel) {
  label.font = .ksr_headline()
}

private func applyIncludedItemsTitleLabelStyle(_ label: UILabel) {
  applyBaseRewardLabelStyle(label)
  applySectionTitleLabelStyle(label)
  label.text = Strings.project_view_pledge_includes()
  label.textColor = LegacyColors.ksr_support_400.uiColor()
}

private func applyEstimatedDeliveryTitleLabelStyle(_ label: UILabel) {
  applyBaseRewardLabelStyle(label)
  applySectionTitleLabelStyle(label)
  label.text = Strings.Estimated_delivery()
  label.textColor = LegacyColors.ksr_support_400.uiColor()
}

private func applyEstimatedShippingTitleLabelStyle(_ label: UILabel) {
  applyBaseRewardLabelStyle(label)
  applySectionTitleLabelStyle(label)
  label.text = Strings.Estimated_Shipping()
  label.textColor = LegacyColors.ksr_support_400.uiColor()
}

private func applyRewardLocationTitleLabelStyle(_ label: UILabel) {
  applyBaseRewardLabelStyle(label)
  applySectionTitleLabelStyle(label)
  label.text = Strings.Reward_location()
  label.textColor = LegacyColors.ksr_support_400.uiColor()
}

private func applyPillsViewStyle(_ view: PillsView) {
  view.backgroundColor = view.backgroundColor
}

private func applySectionStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Styles.grid(1)
}

private func applyDetailsStackViewStyle(_ stackView: UIStackView) {
  stackView.spacing = Styles.grid(3)
  stackView.isLayoutMarginsRelativeArrangement = true
  stackView.layoutMargins = .init(all: Styles.grid(3))
}

private func applyPriceStackViewStyle(_ stackView: UIStackView) {
  stackView.spacing = Styles.gridHalf(1)
}

private func applySectionBodyLabelStyle(_ label: UILabel) {
  label.textColor = LegacyColors.ksr_support_700.uiColor()
  label.font = UIFont.ksr_body()
}

private func applyIncludedItemsStackViewStyle(_ stackView: UIStackView) {
  stackView.spacing = Styles.grid(2)
}

private func applyRewardTitleLabelStyle(_ label: UILabel) {
  label.textColor = LegacyColors.ksr_support_700.uiColor()
  label.font = UIFont.ksr_title2().bolded
}

private func applyMinimumPriceLabelStyle(_ label: UILabel) {
  label.textColor = LegacyColors.ksr_create_700.uiColor()
  label.font = UIFont.ksr_title3().bolded
}

private func applyMinimumPriceConversionLabelStyle(_ label: UILabel) {
  label.textColor = LegacyColors.ksr_create_700.uiColor()
  label.font = UIFont.ksr_caption1().bolded
}

private func applyRewardImageViewStyle(_ imageView: UIImageView) {
  imageView.contentMode = .scaleAspectFill
  imageView.clipsToBounds = true
}

// MARK: - UICollectionViewDelegate

extension RewardCardView: UICollectionViewDelegate {
  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    guard let pillCell = cell as? PillCell else { return }

    pillCell.label.preferredMaxLayoutWidth = collectionView.bounds.width
  }
}

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.backgroundColor = Colors.Background.Surface.primary.uiColor()
  stackView.rounded(with: Styles.grid(3))
}
