import KsApi
import Library
import Prelude

internal protocol RewardCellDelegate: class {
  /// Called when the reward cell needs to perform an expansion animation.
  func rewardCellWantsExpansion(_ cell: RewardCell)
}

internal final class RewardCell: UITableViewCell, ValueCell {
  internal var delegate: RewardCellDelegate?
  fileprivate let viewModel: RewardCellViewModelType = RewardCellViewModel()

  @IBOutlet fileprivate weak var allGoneContainerView: UIView!
  @IBOutlet fileprivate weak var allGoneLabel: UILabel!
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var checkmarkImageView: UIImageView!
  @IBOutlet fileprivate weak var conversionLabel: UILabel!
  @IBOutlet fileprivate weak var descriptionLabel: UILabel!
  @IBOutlet fileprivate weak var estimatedDeliveryDateLabel: UILabel!
  @IBOutlet fileprivate weak var estimatedDeliveryLabel: UILabel!
  @IBOutlet fileprivate weak var estimatedDeliveryDateStackView: UIStackView!
  @IBOutlet fileprivate weak var footerLabel: UILabel!
  @IBOutlet fileprivate weak var footerStackView: UIStackView!
  @IBOutlet fileprivate weak var includesTitleLabel: UILabel!
  @IBOutlet fileprivate weak var itemsContainerStackView: UIStackView!
  @IBOutlet fileprivate weak var itemsHeaderStackView: UIStackView!
  @IBOutlet fileprivate weak var itemsStackView: UIStackView!
  @IBOutlet fileprivate weak var manageRewardButton: UIButton!
  @IBOutlet fileprivate weak var minimumLabel: UILabel!
  @IBOutlet fileprivate weak var minimumStackView: UIStackView!
  @IBOutlet fileprivate weak var rewardTitleLabel: UILabel!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var selectRewardButton: UIButton!
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate weak var titleDescriptionStackView: UIStackView!
  @IBOutlet fileprivate weak var viewYourPledgeButton: UIButton!
  @IBOutlet fileprivate weak var youreABackerCheckmarkImageView: UIImageView!
  @IBOutlet fileprivate weak var youreABackerContainerView: UIView!
  @IBOutlet fileprivate weak var youreABackerLabel: UILabel!
  @IBOutlet fileprivate weak var youreABackerStackView: UIStackView!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
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
      |> RewardCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
      |> (RewardCell.lens.contentView..UIView.lens.layoutMargins) %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(2), left: Styles.grid(16), bottom: Styles.grid(4), right: Styles.grid(16))
          : .init(top: Styles.grid(1), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))
      }
      |> RewardCell.lens.contentView..UIView.lens.backgroundColor .~ projectCellBackgroundColor()
      |> UIView.lens.contentMode .~ .top

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)
      |> UIStackView.lens.layoutMargins
        .~ .init(top: Styles.grid(3), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    _ = self.minimumStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.titleDescriptionStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.footerStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.estimatedDeliveryDateStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = [self.itemsContainerStackView, self.itemsHeaderStackView, self.itemsStackView]
      ||> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = [self.minimumStackView, self.titleDescriptionStackView,
         self.itemsContainerStackView, self.footerStackView]
      ||> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))
      ||> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    _ = self.allGoneContainerView
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.backgroundColor .~ UIColor.ksr_dark_grey_900
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(1), leftRight: Styles.grid(1))

    _ = self.allGoneLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.text %~ { _ in Strings.All_gone() }

    _ = self.cardView
      |> dropShadowStyleMedium()
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
      |> UILabel.lens.text %~ { _ in Strings.Estimated_delivery() }
      |> UILabel.lens.font .~ .ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.estimatedDeliveryDateLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900

    _ = self.includesTitleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.text %~ { _ in Strings.rewards_info_includes() }

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
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.selectRewardButton
      |> greenButtonStyle
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.isAccessibilityElement .~ false

    _ = self.manageRewardButton
      |> greenBorderButtonStyle
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Manage_your_pledge() }
      |> UIButton.lens.isAccessibilityElement .~ false

    _ = self.viewYourPledgeButton
      |> borderButtonStyle
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.View_your_pledge() }
      |> UIButton.lens.isAccessibilityElement .~ false

    self.viewModel.inputs.boundStyles()
  }
  // swiftlint:enable function_body_length

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
    self.viewYourPledgeButton.rac.hidden = self.viewModel.outputs.viewPledgeButtonHidden
    self.youreABackerContainerView.rac.hidden = self.viewModel.outputs.youreABackerViewHidden
    self.youreABackerLabel.rac.text = self.viewModel.outputs.youreABackerLabelText

    self.viewModel.outputs.cardViewDropShadowHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        let opacity = 0.17
        self?.cardView.layer.shadowOpacity = Float(hidden ? 0.0 : opacity)
    }

    self.viewModel.outputs.cardViewBorderIsVisible
      .observeForUI()
      .observeValues { [weak self] visible in
        self?.cardView.layer.borderColor = UIColor.ksr_grey_400.cgColor
        self?.cardView.layer.borderWidth = visible ? 1.0 : 0.0
        self?.cardView.layer.cornerRadius = 2.0
    }

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
  // swiftlint:enable function_body_length

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
