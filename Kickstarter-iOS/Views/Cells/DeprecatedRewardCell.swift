import KsApi
import Library
import Prelude

internal protocol DeprecatedRewardCellDelegate: AnyObject {
  /// Called when the reward cell needs to perform an expansion animation.
  func rewardCellWantsExpansion(_ cell: DeprecatedRewardCell)
}

internal final class DeprecatedRewardCell: UITableViewCell, ValueCell {
  internal var delegate: DeprecatedRewardCellDelegate?
  fileprivate let viewModel: DeprecatedRewardCellViewModelType = DeprecatedRewardCellViewModel()

  @IBOutlet fileprivate var allGoneContainerView: UIView!
  @IBOutlet fileprivate var allGoneLabel: UILabel!
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var checkmarkImageView: UIImageView!
  @IBOutlet fileprivate var conversionLabel: UILabel!
  @IBOutlet fileprivate var descriptionLabel: UILabel!
  @IBOutlet fileprivate var estimatedDeliveryDateLabel: UILabel!
  @IBOutlet fileprivate var estimatedDeliveryLabel: UILabel!
  @IBOutlet fileprivate var estimatedDeliveryDateStackView: UIStackView!
  @IBOutlet fileprivate var footerLabel: UILabel!
  @IBOutlet fileprivate var footerStackView: UIStackView!
  @IBOutlet fileprivate var includesTitleLabel: UILabel!
  @IBOutlet fileprivate var itemsContainerStackView: UIStackView!
  @IBOutlet fileprivate var itemsHeaderStackView: UIStackView!
  @IBOutlet fileprivate var itemsStackView: UIStackView!
  @IBOutlet fileprivate var manageRewardButton: UIButton!
  @IBOutlet fileprivate var minimumLabel: UILabel!
  @IBOutlet fileprivate var minimumStackView: UIStackView!
  @IBOutlet fileprivate var rewardTitleLabel: UILabel!
  @IBOutlet fileprivate var rootStackView: UIStackView!
  @IBOutlet fileprivate var selectRewardButton: UIButton!
  @IBOutlet fileprivate var shippingLocationsLabel: UILabel!
  @IBOutlet fileprivate var shippingLocationsStackView: UIStackView!
  @IBOutlet fileprivate var shippingLocationsSummaryLabel: UILabel!
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate var titleDescriptionStackView: UIStackView!
  @IBOutlet fileprivate var viewYourPledgeButton: UIButton!
  @IBOutlet fileprivate var youreABackerCheckmarkImageView: UIImageView!
  @IBOutlet fileprivate var youreABackerContainerView: UIView!
  @IBOutlet fileprivate var youreABackerLabel: UILabel!
  @IBOutlet fileprivate var youreABackerStackView: UIStackView!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DeprecatedRewardCell.tapped))
    tapRecognizer.cancelsTouchesInView = false
    tapRecognizer.delaysTouchesBegan = false
    tapRecognizer.delaysTouchesEnded = false
    self.addGestureRecognizer(tapRecognizer)
  }

  @objc fileprivate func tapped() {
    self.viewModel.inputs.tapped()
  }

  internal func configureWith(value: (Project, Either<Reward, Backing>)) {
    self.viewModel.inputs.configureWith(project: value.0, rewardOrBacking: value.1)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> DeprecatedRewardCell.lens.accessibilityTraits .~ UIAccessibilityTraits.button.rawValue
      |> (DeprecatedRewardCell.lens.contentView .. UIView.lens.layoutMargins) %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(2), left: Styles.grid(16), bottom: Styles.grid(4), right: Styles.grid(16))
          : .init(top: Styles.grid(1), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))
      }
      |> DeprecatedRewardCell.lens.contentView .. UIView.lens.backgroundColor .~ projectCellBackgroundColor()
      |> UIView.lens.contentMode .~ .top

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)
      |> UIStackView.lens.layoutMargins .~ .init(
        top: Styles.grid(3), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2)
      )
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.minimumStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.titleDescriptionStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.footerStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = [self.estimatedDeliveryDateStackView, self.shippingLocationsStackView]
      ||> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = [self.itemsContainerStackView, self.itemsHeaderStackView, self.itemsStackView]
      ||> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = [
      self.minimumStackView, self.titleDescriptionStackView,
      self.itemsContainerStackView, self.footerStackView
    ]
      ||> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))
      ||> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.allGoneContainerView
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.backgroundColor .~ UIColor.ksr_soft_black
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(1), leftRight: Styles.grid(1))

    _ = self.allGoneLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.text %~ { _ in Strings.All_gone() }

    _ = self.cardView
      |> darkCardStyle(cornerRadius: 0)
      |> UIView.lens.backgroundColor .~ .white

    _ = self.minimumLabel
      |> UILabel.lens.font .~ .ksr_title2(size: 24)

    _ = self.conversionLabel
      |> UILabel.lens.font .~ UIFont.ksr_caption1().italicized

    _ = self.rewardTitleLabel
      |> UILabel.lens.font .~ .ksr_body(size: 18)
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.descriptionLabel
      |> UILabel.lens.font .~ .ksr_body(size: 16)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.estimatedDeliveryLabel
      |> UILabel.lens.text %~ { _ in Strings.Estimated_delivery().uppercased() }
      |> UILabel.lens.font .~ .ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.estimatedDeliveryDateLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 13)
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.includesTitleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.text %~ { _ in Strings.rewards_info_includes() }

    _ = self.shippingLocationsLabel
      |> UILabel.lens.text %~ { _ in Strings.Ships_to().uppercased() }
      |> UILabel.lens.font .~ .ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.shippingLocationsSummaryLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 13)
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.youreABackerCheckmarkImageView
      |> UIImageView.lens.tintColor .~ .ksr_text_dark_grey_500
      |> UIImageView.lens.image %~ { _ in
        UIImage(named: "checkmark-icon", in: .framework, compatibleWith: nil)
      }

    _ = self.youreABackerContainerView
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.backgroundColor .~ UIColor.ksr_green_500
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.gridHalf(3))

    _ = self.youreABackerLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.textColor .~ .white

    _ = self.youreABackerStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)
      |> UIStackView.lens.alignment .~ .center

    _ = self.checkmarkImageView
      |> UIImageView.lens.tintColor .~ .white

    _ = self.footerLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 13)
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.selectRewardButton
      |> greenButtonStyle
      |> UIButton.lens.layer.cornerRadius .~ 0
      |> UIButton.lens.isUserInteractionEnabled .~ false
      |> UIButton.lens.isAccessibilityElement .~ false

    _ = self.manageRewardButton
      |> greenBorderButtonStyle
      |> UIButton.lens.isUserInteractionEnabled .~ false
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Manage_your_pledge() }
      |> UIButton.lens.isAccessibilityElement .~ false

    _ = self.viewYourPledgeButton
      |> borderButtonStyle
      |> UIButton.lens.isUserInteractionEnabled .~ false
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.View_your_pledge() }
      |> UIButton.lens.isAccessibilityElement .~ false

    self.viewModel.inputs.boundStyles()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.allGoneContainerView.rac.hidden = self.viewModel.outputs.allGoneHidden
    self.conversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.conversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.conversionLabel.rac.textColor = self.viewModel.outputs.minimumAndConversionLabelsColor
    self.descriptionLabel.rac.hidden = self.viewModel.outputs.descriptionLabelHidden
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
    self.estimatedDeliveryDateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryDateLabelText
    self.footerStackView.rac.hidden = self.viewModel.outputs.footerStackViewHidden
    self.footerLabel.rac.text = self.viewModel.outputs.footerLabelText
    self.itemsContainerStackView.rac.hidden = self.viewModel.outputs.itemsContainerHidden
    self.manageRewardButton.rac.hidden = self.viewModel.outputs.manageButtonHidden
    self.minimumLabel.rac.text = self.viewModel.outputs.minimumLabelText
    self.minimumLabel.rac.textColor = self.viewModel.outputs.minimumAndConversionLabelsColor
    self.rewardTitleLabel.rac.hidden = self.viewModel.outputs.titleLabelHidden
    self.rewardTitleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.rewardTitleLabel.rac.textColor = self.viewModel.outputs.titleLabelTextColor
    self.selectRewardButton.rac.hidden = self.viewModel.outputs.pledgeButtonHidden
    self.selectRewardButton.rac.title = self.viewModel.outputs.pledgeButtonTitleText
    self.shippingLocationsStackView.rac.hidden = self.viewModel.outputs.shippingLocationsStackViewHidden
    self.shippingLocationsSummaryLabel.rac.text = self.viewModel.outputs.shippingLocationsSummaryLabelText
    self.viewYourPledgeButton.rac.hidden = self.viewModel.outputs.viewPledgeButtonHidden
    self.youreABackerContainerView.rac.hidden = self.viewModel.outputs.youreABackerViewHidden
    self.youreABackerLabel.rac.text = self.viewModel.outputs.youreABackerLabelText

    self.viewModel.outputs.notifyDelegateRewardCellWantsExpansion
      .observeForUI()
      .observeValues { [weak self] in
        self.doIfSome { $0.delegate?.rewardCellWantsExpansion($0) }
      }

    self.viewModel.outputs.updateTopMarginsForIsBacking
      .observeForUI()
      .observeValues { [weak self] isBacking in
        self?.contentView.layoutMargins.top = Styles.grid(isBacking ? 3 : 1)
      }

    self.viewModel.outputs.items
      .observeForUI()
      .observeValues { [weak self] in self?.load(items: $0) }
  }

  fileprivate func load(items: [String]) {
    self.itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    for item in items {
      let label = UILabel()
        |> UILabel.lens.font .~ .ksr_body(size: 14)
        |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
        |> UILabel.lens.text .~ item
        |> UILabel.lens.numberOfLines .~ 0

      let separator = UIView()
        |> separatorStyle
      separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

      self.itemsStackView.addArrangedSubview(label)
      self.itemsStackView.addArrangedSubview(separator)
    }
  }
}
