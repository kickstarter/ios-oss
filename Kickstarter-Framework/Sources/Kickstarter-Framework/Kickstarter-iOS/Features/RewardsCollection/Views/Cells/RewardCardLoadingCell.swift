import KDS
import Library
import UIKit

#Preview {
  let container = UIView()
  container.backgroundColor = Colors.Background.Surface.secondary.uiColor()

  let cell = RewardCardLoadingCell()
  container.addSubview(cell)

  cell.constrainViewToMargins(in: container)
  cell.configureWith(value: true)

  return container
}

/// Used as a placeholder when Rewards are loading.
final class RewardCardLoadingCell: UICollectionViewCell, ValueCell {
  private let stackView = UIStackView()
  private let priceLabel = UILabel()
  private let titleLabel = UILabel()
  private let descriptionLabel = UILabel()
  private let detailLabel = UILabel()
  private let pledgeButton = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.contentView.addSubview(self.stackView)

    self.stackView.axis = .vertical
    self.stackView.backgroundColor = Colors.Background.Surface.primary.uiColor()

    // This has to match RewardCell, so using the deprecated `Styles.grid` spacing constants.
    let deprecatedSpacing = Styles.grid(3)

    self.stackView.rounded(with: deprecatedSpacing)

    self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: deprecatedSpacing * 2)
      .isActive = true
    self.stackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
    self.stackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true

    self.stackView.translatesAutoresizingMaskIntoConstraints = false

    self.stackView.isLayoutMarginsRelativeArrangement = true
    self.stackView.layoutMargins = UIEdgeInsets(all: deprecatedSpacing)
    self.stackView.spacing = deprecatedSpacing
    self.stackView.alignment = .leading

    self.stackView.addArrangedSubviews([
      self.priceLabel,
      self.titleLabel,
      self.descriptionLabel,
      self.pledgeButton
    ])

    // None of this is actually displayed, because these views have the shimmer effect applied. These are just placeholder strings to get a good width for the shimmer view.
    self.priceLabel.text = Format.currency(1, currencyCode: "USD")
    self.priceLabel.accessibilityLabel = Strings.Loading()
    self.priceLabel.font = UIFont.ksr_title3().bolded

    self.titleLabel.text = Strings.Pledge_without_a_reward()
    self.titleLabel.accessibilityLabel = Strings.Loading()
    self.titleLabel.font = UIFont.ksr_title2().bolded

    self.descriptionLabel.text = Strings.Back_it_because_you_believe_in_it()
    self.descriptionLabel.accessibilityLabel = Strings.Loading()
    self.descriptionLabel.font = UIFont.ksr_body()
    self.descriptionLabel.numberOfLines = 0

    self.pledgeButton.applyStyleConfiguration(KSRButtonStyle.green)
    self.pledgeButton.setTitle(Strings.Select(), for: .normal)
    self.pledgeButton.accessibilityLabel = Strings.Loading()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value _: Bool) {
    self.startLoading()
  }
}

extension RewardCardLoadingCell: ShimmerLoading {
  func shimmerViews() -> [UIView] {
    return [self.titleLabel, self.descriptionLabel, self.priceLabel, self.pledgeButton]
  }
}
