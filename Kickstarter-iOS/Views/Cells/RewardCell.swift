import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift

protocol RewardCellDelegate: class {
  func rewardCellDidTapPledgeButton(_ rewardCell: RewardCell, rewardId: Int)
}

final class RewardCell: UICollectionViewCell, ValueCell {
  internal weak var delegate: RewardCellDelegate?
  private let viewModel: RewardCellViewModelType = RewardCellViewModel()

  private let scrollView = UIScrollView(frame: .zero)
  private let pledgeButtonLayoutGuide = UILayoutGuide()

  // UIStackViews
  private let containerView = UIView(frame: .zero)
  private let baseStackView = UIStackView(frame: .zero)
  private let descriptionStackView = UIStackView(frame: .zero)
  private let includedItemsStackView = UIStackView(frame: .zero)
  private let priceStackView = UIStackView(frame: .zero)

  // UILabels
  private let minimumPriceLabel = UILabel(frame: .zero)
  private let minimumPriceConversionLabel = UILabel(frame: .zero)
  private let rewardTitleLabel = UILabel(frame: .zero)
  private let includedItemsTitleLabel = UILabel(frame: .zero)
  private let descriptionTitleLabel = UILabel(frame: .zero)
  private let descriptionLabel = UILabel(frame: .zero)

  private let pledgeButton = MultiLineButton(type: .custom)

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

    [self.baseStackView,
     self.priceStackView,
     self.includedItemsStackView,
     self.descriptionStackView]
      .forEach { stackView in
        _ = stackView
          |> sectionStackViewStyle
    }

    _ = self.baseStackView
      |> baseStackViewStyle

    _ = self.priceStackView
      |> priceStackViewStyle

    [self.includedItemsTitleLabel, self.descriptionTitleLabel].forEach { label in
      _ = label
        |> baseRewardLabelStyle
        |> sectionTitleLabelStyle
    }

    _ = self.includedItemsTitleLabel
      |> \.text %~ { _ in Strings.project_view_pledge_includes() }

    _ = self.descriptionTitleLabel
      |> \.text %~ { _ in "Description" }

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
        guard let _self = self else { return }

        self?.delegate?.rewardCellDidTapPledgeButton(_self, rewardId: rewardId)
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

    self.containerView.addLayoutGuide(self.pledgeButtonLayoutGuide)

    _ = ([self.priceStackView, self.rewardTitleLabel, self.includedItemsStackView, self.descriptionStackView], self.baseStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([minimumPriceLabel, minimumPriceConversionLabel], self.priceStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.includedItemsTitleLabel], self.includedItemsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.descriptionTitleLabel, self.descriptionLabel], self.descriptionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.pledgeButton, self.contentView)
      |> ksr_addSubviewToParent()

    self.setupConstraints()

    self.pledgeButton.addTarget(self, action: #selector(pledgeButtonTapped), for: .touchUpInside)

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rewardCardTapped))
    self.containerView.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupConstraints() {
    let baseStackView = self.baseStackView
    let containerView = self.containerView
    let pledgeButton = self.pledgeButton
    let pledgeButtonLayoutGuide = self.pledgeButtonLayoutGuide

    // Container view
    NSLayoutConstraint.activate([containerView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor)])

    // Base stack view
    _ = baseStackView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    let containerMargins = containerView.layoutMarginsGuide

    NSLayoutConstraint.activate([baseStackView.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
                                 baseStackView.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
                                 baseStackView.topAnchor.constraint(equalTo: containerMargins.topAnchor)
      ])

    // Pledge button
    _ = pledgeButton
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    let topConstraint = pledgeButton.topAnchor.constraint(equalTo: pledgeButtonLayoutGuide.topAnchor)
    _ = topConstraint
      |> \.priority .~ .defaultLow
      |> \.isActive .~ true

    let contentMargins = self.contentView.layoutMarginsGuide

    NSLayoutConstraint.activate([pledgeButton.leftAnchor.constraint(equalTo: contentMargins.leftAnchor),
                                 pledgeButton.rightAnchor.constraint(equalTo: contentMargins.rightAnchor),
                                 // swiftlint:disable:next line_length
                                 pledgeButton.bottomAnchor.constraint(lessThanOrEqualTo: contentMargins.bottomAnchor),
                                 // swiftlint:disable:next line_length
                                 pledgeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
      ])

    // Pledge button layout anchor
    NSLayoutConstraint.activate([
      pledgeButtonLayoutGuide.bottomAnchor.constraint(equalTo: containerMargins.bottomAnchor),
      pledgeButtonLayoutGuide.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
      pledgeButtonLayoutGuide.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
      pledgeButtonLayoutGuide.topAnchor.constraint(equalTo: baseStackView.bottomAnchor,
                                                   constant: Styles.grid(3)),
      pledgeButtonLayoutGuide.heightAnchor.constraint(equalTo: pledgeButton.heightAnchor)
      ])
  }

  fileprivate func load(items: [String]) {
    self.includedItemsStackView.subviews.forEach { $0.removeFromSuperview() }

    let includedItemViews = items.enumerated().map { (index, item) -> [UIView] in
      let label = UILabel()
        |> baseRewardLabelStyle
        |> sectionBodyLabelStyle
        |> \.text .~ item

      let separator = UIView()
        |> separatorStyle
      separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

      var itemViews: [UIView] = [label]

      if index != items.endIndex - 1 {
        itemViews.append(separator)
      }

      return itemViews
    }.flatMap { $0 }

    let allItemViews = [self.includedItemsTitleLabel] + includedItemViews

    _ = (allItemViews, self.includedItemsStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  internal func configureWith(value: (Project, Either<Reward, Backing>)) {
    self.viewModel.inputs.configureWith(project: value.0, rewardOrBacking: value.1)
  }

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
}

private let baseStackViewStyle: StackViewStyle = { stackView in
  stackView
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
