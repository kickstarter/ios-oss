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

  weak var delegate: RewardCellDelegate?
  private let viewModel: RewardCellViewModelType = RewardCellViewModel()

  private let baseStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let containerView = UIView(frame: .zero)
  private let descriptionLabel = UILabel(frame: .zero)
  private let descriptionStackView = UIStackView(frame: .zero)
  private let descriptionTitleLabel = UILabel(frame: .zero)

  private let includedItemsStackView = UIStackView(frame: .zero)
  private let includedItemsTitleLabel = UILabel(frame: .zero)
  private let minimumPriceConversionLabel = UILabel(frame: .zero)
  private let minimumPriceLabel = UILabel(frame: .zero)
  private let pledgeButton: MultiLineButton = {
    MultiLineButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let pledgeButtonLayoutGuide = UILayoutGuide()
  private let priceStackView = UIStackView(frame: .zero)
  private let rewardTitleLabel = UILabel(frame: .zero)
  private let scrollView = UIScrollView(frame: .zero)
  private let stateImageView: UIImageView = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let stateImageViewContainer: UIView = {
    UIView(frame: .zero)
      |> \.isHidden .~ true
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let titleStackView = UIStackView(frame: .zero)

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.pledgeButton
      |> checkoutGreenButtonStyle

    _ = self.pledgeButton.titleLabel
      ?|> checkoutGreenButtonTitleLabelStyle

    _ = self.scrollView
      |> scrollViewStyle

    _ = [
      self.baseStackView,
      self.priceStackView,
      self.includedItemsStackView,
      self.descriptionStackView
    ]
      ||> { stackView in
        stackView
          |> sectionStackViewStyle
      }

    _ = self.baseStackView
      |> baseStackViewStyle

    _ = self.priceStackView
      |> priceStackViewStyle

    _ = [self.includedItemsTitleLabel, self.descriptionTitleLabel]
      ||> { label in
        label
          |> baseRewardLabelStyle
          |> sectionTitleLabelStyle
      }

    _ = self.includedItemsTitleLabel
      |> \.text %~ { _ in Strings.project_view_pledge_includes() }

    _ = self.includedItemsStackView.subviews
      .dropFirst()
      .compactMap { $0 as? UILabel }
      ||> baseRewardLabelStyle
      ||> sectionBodyLabelStyle

    _ = self.descriptionTitleLabel
      |> \.text %~ { _ in Strings.Description() }

    _ = self.descriptionLabel
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

    _ = self.stateImageView
      |> stateImageViewStyle

    _ = self.stateImageViewContainer
      |> stateImageViewContainerStyle

    _ = self.titleStackView
      |> titleStackViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.minimumPriceConversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.minimumPriceConversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.includedItemsStackView.rac.hidden = self.viewModel.outputs.includedItemsStackViewHidden
    self.minimumPriceLabel.rac.text = self.viewModel.outputs.rewardMinimumLabelText
    self.rewardTitleLabel.rac.hidden = self.viewModel.outputs.rewardTitleLabelHidden
    self.rewardTitleLabel.rac.text = self.viewModel.outputs.rewardTitleLabelText
    self.pledgeButton.rac.title = self.viewModel.outputs.pledgeButtonTitleText
    self.pledgeButton.rac.enabled = self.viewModel.outputs.pledgeButtonEnabled

    self.viewModel.outputs.items
      .observeForUI()
      .observeValues { [weak self] in self?.load(items: $0) }

    self.viewModel.outputs.rewardSelected
      .observeForUI()
      .observeValues { [weak self] rewardId in
        guard let self = self else { return }

        self.delegate?.rewardCellDidTapPledgeButton(self, rewardId: rewardId)
      }

    self.viewModel.outputs.cardUserInteractionIsEnabled
      .observeForUI()
      .observeValues { [weak self] isUserInteractionEnabled in
        _ = self?.containerView
          ?|> \.isUserInteractionEnabled .~ isUserInteractionEnabled
      }
  }

  // MARK: - Private Helpers

  private func configureViews() {
    _ = self.contentView
      |> \.layoutMargins .~ .init(all: Styles.grid(3))
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.containerView
      |> checkoutWhiteBackgroundStyle
      |> roundedStyle(cornerRadius: Styles.grid(3))
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = (self.scrollView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.containerView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.baseStackView, self.containerView)
      |> ksr_addSubviewToParent()

    _ = (self.pledgeButtonLayoutGuide, self.containerView)
      |> ksr_addLayoutGuideToView()

    let baseSubviews = [
      self.titleStackView, self.rewardTitleLabel, self.includedItemsStackView, self.descriptionStackView
    ]

    _ = (baseSubviews, self.baseStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.minimumPriceLabel, self.minimumPriceConversionLabel], self.priceStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.includedItemsTitleLabel], self.includedItemsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.descriptionTitleLabel, self.descriptionLabel], self.descriptionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.pledgeButton, self.contentView)
      |> ksr_addSubviewToParent()

    _ = (self.stateImageView, self.stateImageViewContainer)
      |> ksr_addSubviewToParent()

    _ = ([self.priceStackView, self.stateImageViewContainer], self.titleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.setupConstraints()

    self.pledgeButton.addTarget(self, action: #selector(self.pledgeButtonTapped), for: .touchUpInside)

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.rewardCardTapped))
    self.containerView.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupConstraints() {
    let containerConstraints = [
      self.containerView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor)
    ]

    let containerMargins = self.containerView.layoutMarginsGuide

    let baseStackViewConstraints = [
      self.baseStackView.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
      self.baseStackView.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
      self.baseStackView.topAnchor.constraint(equalTo: containerMargins.topAnchor)
    ]

    let imageViewContraints = [
      self.stateImageView.widthAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.stateImageView.heightAnchor.constraint(equalTo: self.stateImageView.widthAnchor),
      self.stateImageView.centerXAnchor.constraint(equalTo: self.stateImageViewContainer.centerXAnchor),
      self.stateImageView.centerYAnchor.constraint(equalTo: self.stateImageViewContainer.centerYAnchor),
      self.stateImageViewContainer.widthAnchor.constraint(equalToConstant: Styles.grid(5)),
      self.stateImageViewContainer.heightAnchor.constraint(equalTo: self.stateImageViewContainer.widthAnchor)
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
      self.pledgeButtonLayoutGuide.topAnchor.constraint(equalTo: self.baseStackView.bottomAnchor, constant: Styles.grid(3)),
      self.pledgeButtonLayoutGuide.heightAnchor.constraint(equalTo: pledgeButton.heightAnchor)
    ]

    NSLayoutConstraint.activate([
      containerConstraints,
      baseStackViewConstraints,
      imageViewContraints,
      pledgeButtonConstraints,
      pledgeButtonLayoutGuideConstraints
    ].flatMap { $0 })
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

  internal func configureWith(value: (Project, Either<Reward, Backing>)) {
    self.viewModel.inputs.configureWith(project: value.0, rewardOrBacking: value.1)
  }

  // MARK: - Selectors

  @objc func pledgeButtonTapped() {
    self.viewModel.inputs.pledgeButtonTapped()
  }

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
    |> \.backgroundColor .~ .white
}

private let baseStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.backgroundColor .~ .white
    |> \.spacing .~ Styles.grid(3)
}

private let minimumPriceLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_green_500
    |> \.font .~ UIFont.ksr_headline(size: 24).bolded
}

private let minimumPriceConversionLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_green_500
    |> \.font .~ UIFont.ksr_headline(size: 13)
}

private let priceStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(1)
}

private let rewardTitleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ UIFont.ksr_headline(size: 24).bolded
}

private let scrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> \.backgroundColor .~ .clear
    |> \.contentInset .~ .init(topBottom: Styles.grid(6))
    |> \.showsVerticalScrollIndicator .~ false
}

private let sectionStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.alignment .~ .fill
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(2)
}

private let sectionTitleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_text_dark_grey_400
    |> \.font .~ .ksr_headline()
}

private let sectionBodyLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ .ksr_callout()
}

private let stateImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ UIImage(named: "checkmark-reward")
    |> \.tintColor .~ UIColor.ksr_blue_500
}

private let stateImageViewContainerStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ UIColor.ksr_blue_500.withAlphaComponent(0.06)
    |> \.layer.cornerRadius .~ 15
}

private let titleStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.alignment .~ UIStackView.Alignment.center
}
