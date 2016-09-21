import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectPamphletMainCell: UITableViewCell, ValueCell {
  private let viewModel: ProjectPamphletMainCellViewModelType = ProjectPamphletMainCellViewModel()

  @IBOutlet private weak var backersSubtitleLabel: UILabel!
  @IBOutlet private weak var backersTitleLabel: UILabel!
  @IBOutlet private weak var blurbAndReadMoreStackView: UIStackView!
  @IBOutlet private weak var contentStackView: UIStackView!
  @IBOutlet private weak var conversionLabel: UILabel!
  @IBOutlet private weak var creatorImageView: UIImageView!
  @IBOutlet private weak var creatorLabel: UILabel!
  @IBOutlet private weak var creatorStackView: UIStackView!
  @IBOutlet private weak var deadlineSubtitleLabel: UILabel!
  @IBOutlet private weak var deadlineTitleLabel: UILabel!
  @IBOutlet private weak var fundingProgressBarView: UIView!
  @IBOutlet private weak var fundingProgressContainerView: UIView!
  @IBOutlet private weak var pledgeSubtitleLabel: UILabel!
  @IBOutlet private weak var pledgedTitleLabel: UILabel!
  @IBOutlet private weak var projectBlurbLabel: UILabel!
  @IBOutlet private weak var projectImageContainerView: UIView!
  @IBOutlet private weak var projectImageOverlayView: UIView!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectNameAndCreatorStackView: UIStackView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var progressBarAndStatsStackView: UIStackView!
  @IBOutlet private weak var readMoreButton: UIButton!
  @IBOutlet private weak var youreABackerContainerView: UIView!
  @IBOutlet private weak var youreABackerLabel: UILabel!

  internal func configureWith(value project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal func scrollContentOffset(offset: CGPoint) {
    let scaleFactor = max(1, 1 - 2 * offset.y / self.projectImageContainerView.bounds.height)
    let scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
    let translate = CGAffineTransformMakeTranslation(0, max(0, offset.y / 4))
    self.projectImageContainerView.transform = CGAffineTransformConcat(translate, scale)
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.clipsToBounds .~ false

    self.backersSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.dashboard_tout_backers() }

    [self.backersSubtitleLabel, self.deadlineSubtitleLabel, self.pledgeSubtitleLabel]
      ||> UILabel.lens.textColor .~ .ksr_text_navy_500
      ||> UILabel.lens.font .~ .ksr_caption1(size: 13)
      ||> UILabel.lens.numberOfLines .~ 2

    [self.backersTitleLabel, self.deadlineTitleLabel, self.pledgedTitleLabel]
      ||> UILabel.lens.textColor .~ .ksr_text_navy_700
      ||> UILabel.lens.font .~ .ksr_headline(size: 13)

    self.blurbAndReadMoreStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.contentStackView
      |> UIStackView.lens.layoutMargins %~~ { _, stackView in

        stackView.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : .init(top: Styles.grid(4), left: Styles.grid(4), bottom: Styles.grid(3), right: Styles.grid(4))
      }
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(4)

    self.conversionLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.font .~ UIFont.ksr_caption2().italicized
      |> UILabel.lens.numberOfLines .~ 2

    self.creatorImageView
      |> UIImageView.lens.clipsToBounds .~ true
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill

    self.creatorLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_headline(size: 13)

    self.creatorStackView
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    self.fundingProgressContainerView
      |> UIView.lens.backgroundColor .~ .ksr_navy_400

    self.fundingProgressBarView
      |> UIView.lens.backgroundColor .~ .ksr_green_700

    self.projectBlurbLabel
      |> UILabel.lens.font .~ .ksr_body(size: 15)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.numberOfLines .~ 0

    self.projectImageView
      |> UIImageView.lens.clipsToBounds .~ true
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill

    self.projectNameAndCreatorStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_title3(size: 20)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.numberOfLines .~ 0

    self.progressBarAndStatsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.readMoreButton
      |> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_green_700
      |> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_700
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Read_more_about_the_campaign_arrow() }

    self.youreABackerContainerView
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.backgroundColor .~ .ksr_green_700
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.gridHalf(3))

    self.youreABackerLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.text %~ { _ in Strings.Youre_a_backer() }
  }
  // swiftlint:enable function_body_length

  internal override func bindViewModel() {
    super.bindViewModel()

    self.backersTitleLabel.rac.text = self.viewModel.outputs.backersTitleLabelText
    self.conversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.conversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.creatorLabel.rac.text = self.viewModel.outputs.creatorLabelText
    self.deadlineSubtitleLabel.rac.text = self.viewModel.outputs.deadlineSubtitleLabelText
    self.deadlineTitleLabel.rac.text = self.viewModel.outputs.deadlineTitleLabelText
    self.pledgeSubtitleLabel.rac.text = self.viewModel.outputs.pledgedSubtitleLabelText
    self.pledgedTitleLabel.rac.text = self.viewModel.outputs.pledgedTitleLabelText
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameLabelText
    self.projectBlurbLabel.rac.text = self.viewModel.outputs.projectBlurbLabelText
    self.youreABackerContainerView.rac.hidden = self.viewModel.outputs.youreABackerLabelHidden

    self.viewModel.outputs.creatorImageUrl
      .observeForUI()
      .on(next: { [weak self] _ in self?.creatorImageView.image = nil })
      .ignoreNil()
      .observeNext { [weak self] in self?.creatorImageView.af_setImageWithURL($0) }

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(next: { [weak self] _ in self?.projectImageView.image = nil })
      .ignoreNil()
      .observeNext { [weak self] in self?.projectImageView.af_setImageWithURL($0) }

    self.viewModel.outputs.progressPercentage
      .observeForUI()
      .observeNext { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }

  }
}
