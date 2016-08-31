import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectHeaderViewControllerDelegate: class {
  func projectHeaderShowCampaignTab()
  func projectHeaderShowRewardsTab()
}

internal final class ProjectHeaderViewController: UIViewController {
  private let viewModel: ProjectHeaderViewModelType = ProjectHeaderViewModel()
  internal weak var delegate: ProjectHeaderViewControllerDelegate?

  @IBOutlet private weak var allStatsStackView: UIStackView!
  @IBOutlet private weak var backersSubtitleLabel: UILabel!
  @IBOutlet private weak var backersTitleLabel: UILabel!
  @IBOutlet private weak var campaignRewardsStackView: UIStackView!
  @IBOutlet private weak var campaignTabButton: UIButton!
  @IBOutlet private weak var campaignTabSelectedView: UIView!
  @IBOutlet private weak var commentsButton: UIButton!
  @IBOutlet private weak var commentsSubtitleLabel: UILabel!
  @IBOutlet private weak var commentsTitleLabel: UILabel!
  @IBOutlet private weak var conversionLabel: UILabel!
  @IBOutlet private weak var deadlineSubtitleLabel: UILabel!
  @IBOutlet private weak var deadlineTitleLabel: UILabel!
  @IBOutlet private weak var mainInfoStackView: UIStackView!
  @IBOutlet private weak var pledgeSubtitleLabel: UILabel!
  @IBOutlet private weak var pledgedTitleLabel: UILabel!
  @IBOutlet private weak var progressBarView: UIView!
  @IBOutlet private weak var projectNameAndBlurbLabel: SimpleHTMLLabel!
  @IBOutlet private weak var projectStateAndProgressStackView: UIStackView!
  @IBOutlet private weak var projectStateLabel: UILabel!
  @IBOutlet private weak var rewardsButton: UIButton!
  @IBOutlet private weak var rewardsSubtitleLabel: UILabel!
  @IBOutlet private weak var rewardsTabButton: UIButton!
  @IBOutlet private weak var rewardsTabSelectedView: UIView!
  @IBOutlet private weak var rewardsTitleLabel: UILabel!
  @IBOutlet private weak var rootBackgroundView: UIView!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private var statStackViews: [UIStackView]!
  @IBOutlet private var subpageHolderViews: [UIView]!
  @IBOutlet private weak var subpagesStackView: UIStackView!
  @IBOutlet private var subpageStackViews: [UIStackView]!
  @IBOutlet private weak var updatesButton: UIButton!
  @IBOutlet private weak var updatesSubtitleLabel: UILabel!
  @IBOutlet private weak var updatesTitleLabel: UILabel!
  private var videoViewController: VideoViewController!
  @IBOutlet private weak var youreABackerLabel: UILabel!

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.rewardsButton.addTarget(self,
                                 action: #selector(rewardsButtonTapped),
                                 forControlEvents: .TouchUpInside)
    self.commentsButton.addTarget(self,
                                  action: #selector(commentsButtonTapped),
                                  forControlEvents: .TouchUpInside)
    self.updatesButton.addTarget(self,
                                 action: #selector(updatesButtonTapped),
                                 forControlEvents: .TouchUpInside)
    self.campaignTabButton.addTarget(self,
                                     action: #selector(campaignTabButtonTapped),
                                     forControlEvents: .TouchUpInside)
    self.rewardsTabButton.addTarget(self,
                                    action: #selector(rewardsTabButtonTapped),
                                    forControlEvents: .TouchUpInside)

    self.videoViewController = self.childViewControllers
      .flatMap { $0 as? VideoViewController }
      .first

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .clearColor()

    self.rootBackgroundView
      |> UIView.lens.backgroundColor .~ .ksr_grey_200

    self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(5)

    self.mainInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.projectNameAndBlurbLabel
      |> projectNameAndBlurbStyle

    [self.mainInfoStackView, self.subpagesStackView]
      ||> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))
      ||> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    [self.pledgedTitleLabel, self.backersTitleLabel, self.deadlineTitleLabel]
      ||> projectStatTitleStlye

    [self.pledgeSubtitleLabel, self.backersSubtitleLabel, self.deadlineSubtitleLabel]
      ||> projectStatSubtitleStyle

    self.pledgedTitleLabel
      |> UILabel.lens.textColor .~ UIColor.ksr_text_green_700

    self.statStackViews
      ||> UIStackView.lens.spacing .~ 2

    self.allStatsStackView
      |> UIStackView.lens.isAccessibilityElement .~ true

    self.subpagesStackView
      |> UIStackView.lens.distribution .~ .FillEqually
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    [self.campaignTabButton, self.rewardsTabButton]
      ||> subpageTabButtonStyle

    self.campaignTabButton
      |> UIButton.lens.title(forState: .Normal) %~ { _ in  Strings.project_menu_buttons_campaign() }

    [self.rewardsTitleLabel, self.commentsTitleLabel, self.updatesTitleLabel]
      ||> UILabel.lens.textColor .~ .ksr_text_navy_700
      ||> UILabel.lens.font .~ .ksr_headline(size: 14.0)
      ||> UILabel.lens.isAccessibilityElement .~ false

    [self.rewardsSubtitleLabel, self.commentsSubtitleLabel, self.updatesSubtitleLabel]
      ||> UILabel.lens.textColor .~ .ksr_text_navy_500
      ||> UILabel.lens.font .~ .ksr_subhead(size: 14.0)
      ||> UILabel.lens.isAccessibilityElement .~ false

    self.rewardsSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.project_subpages_menu_buttons_rewards() }

    self.commentsSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.project_subpages_menu_buttons_comments() }

    self.updatesSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.project_subpages_menu_buttons_updates() }

    [self.rewardsButton, self.commentsButton, self.updatesButton]
      ||> cardStyle()
      ||> UIButton.lens.backgroundColor .~ .clearColor()
      ||> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_grey_500
      ||> UIButton.lens.backgroundColor(forState: .Selected) .~ .ksr_grey_500

    self.rewardsButton
      |> UIButton.lens.accessibilityHint %~ { _ in
        localizedString(key: "key.todo", defaultValue: "Opens rewards.")
    }

    self.commentsButton
      |> UIButton.lens.accessibilityHint %~ { _ in
        localizedString(key: "key.todo", defaultValue: "Opens comments.")
    }

    self.updatesButton
      |> UIButton.lens.accessibilityHint %~ { _ in
        localizedString(key: "key.todo", defaultValue: "Opens updates.")
    }

    self.subpageStackViews
      ||> UIStackView.lens.spacing .~ -2
      ||> UIStackView.lens.alignment .~ .Center
      ||> UIStackView.lens.userInteractionEnabled .~ false

    self.subpageHolderViews
      ||> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: 0)
      ||> UIView.lens.backgroundColor .~ .clearColor()

    [self.campaignTabSelectedView, self.rewardsTabSelectedView]
      ||> UIView.lens.backgroundColor .~ .ksr_navy_700

    self.conversionLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.font .~ UIFont.ksr_caption2().italicized
      |> UILabel.lens.numberOfLines .~ 2

    self.projectStateAndProgressStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.projectStateLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.numberOfLines .~ 1
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.minimumScaleFactor .~ 0.5
      |> UILabel.lens.adjustsFontSizeToFitWidth .~ true

    self.youreABackerLabel
      |> UILabel.lens.textColor .~ .ksr_text_green_700
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.text %~ { _ in
        localizedString(key: "key.todo", defaultValue: "You’re a backer!")
    }
  }
  // swiftlint:enable function_body_length

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.allStatsStackView.rac.accessibilityValue = self.viewModel.outputs.allStatsStackViewAccessibilityValue
    self.youreABackerLabel.rac.hidden = self.viewModel.outputs.youreABackerLabelHidden
    self.backersTitleLabel.rac.text = self.viewModel.outputs.backersTitleLabelText
    self.campaignTabButton.rac.selected = self.viewModel.outputs.campaignButtonSelected
    self.campaignTabSelectedView.rac.hidden = self.viewModel.outputs.campaignSelectedViewHidden
    self.commentsButton.rac.accessibilityValue = self.viewModel.outputs.commentsButtonAccessibilityLabel
    self.commentsTitleLabel.rac.text = self.viewModel.outputs.commentsLabelText
    self.conversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.conversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.deadlineSubtitleLabel.rac.text = self.viewModel.outputs.deadlineSubtitleLabelText
    self.deadlineTitleLabel.rac.text = self.viewModel.outputs.deadlineTitleLabelText
    self.pledgedTitleLabel.rac.text = self.viewModel.outputs.pledgedTitleLabelText
    self.pledgeSubtitleLabel.rac.text = self.viewModel.outputs.pledgedSubtitleLabelText
    self.projectNameAndBlurbLabel.rac.html = self.viewModel.outputs.projectNameAndBlurbLabelText
    self.projectStateLabel.rac.hidden = self.viewModel.outputs.projectStateLabelHidden
    self.projectStateLabel.rac.text = self.viewModel.outputs.projectStateLabelText
    self.rewardsButton.rac.accessibilityLabel = self.viewModel.outputs.rewardsButtonAccessibilityLabel
    self.rewardsTabButton.rac.accessibilityLabel = self.viewModel.outputs.rewardsButtonAccessibilityLabel
    self.rewardsTabButton.rac.selected = self.viewModel.outputs.rewardsTabButtonSelected
    self.rewardsTabButton.rac.title = self.viewModel.outputs.rewardsTabButtonTitleText
    self.rewardsTabSelectedView.rac.hidden = self.viewModel.outputs.rewardsSelectedViewHidden
    self.rewardsTitleLabel.rac.text = self.viewModel.outputs.rewardsLabelText
    self.updatesButton.rac.accessibilityLabel = self.viewModel.outputs.updatesButtonAccessibilityLabel
    self.updatesTitleLabel.rac.text = self.viewModel.outputs.updatesLabelText

    self.viewModel.outputs.configureVideoViewControllerWithProject
      .observeForControllerAction()
      .observeNext { [weak self] project in self?.videoViewController.configureWith(project: project) }

    self.viewModel.outputs.goToComments
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToComments(project: $0) }

    self.viewModel.outputs.goToUpdates
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToUpdates(forProject: $0) }

    self.viewModel.outputs.notifyDelegateToShowCampaignTab
      .observeNext { [weak self] in self?.delegate?.projectHeaderShowCampaignTab() }

    self.viewModel.outputs.notifyDelegateToShowRewardsTab
      .observeNext { [weak self] in self?.delegate?.projectHeaderShowRewardsTab() }

    self.viewModel.outputs.progressPercentage
      .observeForControllerAction()
      .observeNext { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.progressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.progressBarView.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }
  }
  // swiftlint:enable function_body_length

  private func goToComments(project project: Project) {
    let vc = CommentsViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToUpdates(forProject project: Project) {
    let vc = ProjectUpdatesViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @objc private func rewardsButtonTapped() {
    self.viewModel.inputs.rewardsButtonTapped()
  }

  @objc private func commentsButtonTapped() {
    self.viewModel.inputs.commentsButtonTapped()
  }

  @objc private func updatesButtonTapped() {
    self.viewModel.inputs.updatesButtonTapped()
  }

  @objc private func campaignTabButtonTapped() {
    self.viewModel.inputs.campaignTabButtonTapped()
  }

  @objc private func rewardsTabButtonTapped() {
    self.viewModel.inputs.rewardsTabButtonTapped()
  }
}
