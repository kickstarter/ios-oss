import KsApi
import Library
import Prelude
import UIKit

internal protocol ProjectPamphletMainCellDelegate: VideoViewControllerDelegate {
  func projectPamphletMainCell(cell: ProjectPamphletMainCell, addChildController child: UIViewController)
  func projectPamphletMainCell(cell: ProjectPamphletMainCell, goToCampaignForProject project: Project)
  func projectPamphletMainCell(cell: ProjectPamphletMainCell, goToCreatorForProject project: Project)
}

internal final class ProjectPamphletMainCell: UITableViewCell, ValueCell {
  internal weak var delegate: ProjectPamphletMainCellDelegate? {
    didSet {
      self.viewModel.inputs.delegateDidSet()
    }
  }
  private let viewModel: ProjectPamphletMainCellViewModelType = ProjectPamphletMainCellViewModel()

  private weak var videoController: VideoViewController?

  @IBOutlet private weak var backersSubtitleLabel: UILabel!
  @IBOutlet private weak var backersTitleLabel: UILabel!
  @IBOutlet private weak var blurbAndReadMoreStackView: UIStackView!
  @IBOutlet private weak var contentStackView: UIStackView!
  @IBOutlet private weak var conversionLabel: UILabel!
  @IBOutlet private weak var creatorButton: UIButton!
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
  @IBOutlet private weak var projectNameAndCreatorStackView: UIStackView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var progressBarAndStatsStackView: UIStackView!
  @IBOutlet private weak var readMoreButton: UIButton!
  @IBOutlet private weak var stateLabel: UILabel!
  @IBOutlet private weak var statsStackView: UIStackView!
  @IBOutlet private weak var youreABackerContainerView: UIView!
  @IBOutlet private weak var youreABackerLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.creatorButton.addTarget(self,
                                 action: #selector(creatorButtonTapped),
                                 forControlEvents: .TouchUpInside)
    self.readMoreButton.addTarget(self,
                                  action: #selector(readMoreButtonTapped),
                                  forControlEvents: .TouchUpInside)
  }

  internal func configureWith(value project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal func scrollContentOffset(offset: CGFloat) {

    let height = self.projectImageContainerView.bounds.height
    let translation = offset / 2

    let scale: CGFloat
    if offset < 0 {
      scale = (height + abs(offset)) / height
    } else {
      scale = max(1, 1 - 0.5 * offset / height)
    }

    self.projectImageContainerView.transform = CGAffineTransform(
      a: scale, b: 0,
      c: 0, d: scale,
      tx: 0, ty: translation)
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.clipsToBounds .~ true
      |> UITableViewCell.lens.accessibilityElements .~ self.subviews

    [self.backersSubtitleLabel, self.deadlineSubtitleLabel, self.pledgeSubtitleLabel]
      ||> UILabel.lens.textColor .~ .ksr_text_navy_500
      ||> UILabel.lens.font .~ .ksr_caption1(size: 13)
      ||> UILabel.lens.numberOfLines .~ 2

    [self.backersTitleLabel, self.deadlineTitleLabel, self.pledgedTitleLabel]
      ||> UILabel.lens.font .~ .ksr_headline(size: 13)

    self.blurbAndReadMoreStackView
      |> UIStackView.lens.spacing .~ 0

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

    self.creatorButton
      |> UIButton.lens.accessibilityHint %~ { _ in
        localizedString(key: "Opens_creator_profile", defaultValue: "Opens creator profile.")
      }

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

    self.projectBlurbLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_body(size: 18)
          : .ksr_body(size: 15)
      }
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.numberOfLines .~ 0

    self.projectNameAndCreatorStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.projectNameLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_title3(size: 28)
          : .ksr_title3(size: 20)
      }
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.numberOfLines .~ 0

    self.progressBarAndStatsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.readMoreButton
      |> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_700
      |> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_500
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Read_more_about_the_campaign_arrow() }
      |> UIButton.lens.contentEdgeInsets .~ .init(top: Styles.grid(3) - 1,
                                                  left: 0,
                                                  bottom: Styles.grid(4) - 1,
                                                  right: 0)

    self.stateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.numberOfLines .~ 2

    self.statsStackView
      |> UIStackView.lens.isAccessibilityElement .~ true

    self.youreABackerContainerView
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.backgroundColor .~ .ksr_green_500
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.gridHalf(3))

    self.youreABackerLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.text %~ { _ in Strings.Youre_a_backer() }
  }
  // swiftlint:enable function_body_length

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.backersSubtitleLabel.rac.text = self.viewModel.outputs.backersSubtitleLabelText
    self.backersTitleLabel.rac.text = self.viewModel.outputs.backersTitleLabelText
    self.backersTitleLabel.rac.textColor = self.viewModel.outputs.projectUnsuccessfulLabelTextColor
    self.conversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.conversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.creatorButton.rac.accessibilityLabel = self.viewModel.outputs.creatorLabelText
    self.creatorLabel.rac.text = self.viewModel.outputs.creatorLabelText
    self.deadlineSubtitleLabel.rac.text = self.viewModel.outputs.deadlineSubtitleLabelText
    self.deadlineTitleLabel.rac.text = self.viewModel.outputs.deadlineTitleLabelText
    self.deadlineTitleLabel.rac.textColor = self.viewModel.outputs.projectUnsuccessfulLabelTextColor
    self.fundingProgressBarView.rac.backgroundColor =
      self.viewModel.outputs.fundingProgressBarViewBackgroundColor
    self.pledgeSubtitleLabel.rac.text = self.viewModel.outputs.pledgedSubtitleLabelText
    self.pledgedTitleLabel.rac.text = self.viewModel.outputs.pledgedTitleLabelText
    self.pledgedTitleLabel.rac.textColor = self.viewModel.outputs.pledgedTitleLabelTextColor
    self.projectBlurbLabel.rac.text = self.viewModel.outputs.projectBlurbLabelText
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameLabelText
    self.stateLabel.rac.text = self.viewModel.outputs.projectStateLabelText
    self.stateLabel.rac.textColor = self.viewModel.outputs.projectStateLabelTextColor
    self.stateLabel.rac.hidden = self.viewModel.outputs.stateLabelHidden
    self.statsStackView.rac.accessibilityLabel = self.viewModel.outputs.statsStackViewAccessibilityLabel
    self.youreABackerContainerView.rac.hidden = self.viewModel.outputs.youreABackerLabelHidden

    self.viewModel.outputs.configureVideoPlayerController
      .observeForUI()
      .observeNext { [weak self] in self?.configureVideoPlayerController(forProject: $0) }

    self.viewModel.outputs.creatorImageUrl
      .observeForUI()
      .on(next: { [weak self] _ in self?.creatorImageView.image = nil })
      .ignoreNil()
      .observeNext { [weak self] in self?.creatorImageView.af_setImageWithURL($0) }

    self.viewModel.outputs.notifyDelegateToGoToCampaign
      .observeForControllerAction()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.projectPamphletMainCell(_self, goToCampaignForProject: $0)
    }

    self.viewModel.outputs.notifyDelegateToGoToCreator
      .observeForControllerAction()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.projectPamphletMainCell(_self, goToCreatorForProject: $0)
    }

    self.viewModel.outputs.progressPercentage
      .observeForUI()
      .observeNext { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }
  }
  // swiftlint:enable function_body_length

  private func configureVideoPlayerController(forProject project: Project) {
    let vc = VideoViewController.configuredWith(project: project)
    vc.delegate = self
    vc.view.translatesAutoresizingMaskIntoConstraints = false
    self.projectImageContainerView.addSubview(vc.view)

    NSLayoutConstraint.activateConstraints([
      vc.view.topAnchor.constraintEqualToAnchor(self.projectImageContainerView.topAnchor),
      vc.view.leadingAnchor.constraintEqualToAnchor(self.projectImageContainerView.leadingAnchor),
      vc.view.bottomAnchor.constraintEqualToAnchor(self.projectImageContainerView.bottomAnchor),
      vc.view.trailingAnchor.constraintEqualToAnchor(self.projectImageContainerView.trailingAnchor),
    ])

    self.delegate?.projectPamphletMainCell(self, addChildController: vc)
    self.videoController = vc
  }

  @objc private func readMoreButtonTapped() {
    self.viewModel.inputs.readMoreButtonTapped()
  }

  @objc private func creatorButtonTapped() {
    self.viewModel.inputs.creatorButtonTapped()
  }
}

extension ProjectPamphletMainCell: VideoViewControllerDelegate {
  internal func videoViewControllerDidFinish(controller: VideoViewController) {
    self.delegate?.videoViewControllerDidFinish(controller)
    self.viewModel.inputs.videoDidFinish()
  }

  internal func videoViewControllerDidStart(controller: VideoViewController) {
    self.delegate?.videoViewControllerDidStart(controller)
    self.viewModel.inputs.videoDidStart()
  }
}
