import KsApi
import Library
import Prelude
import Prelude_UIKit
import Social
import UIKit

internal final class ProjectMagazineViewController: UIViewController {
  private let viewModel: ProjectMagazineViewModelType = ProjectMagazineViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  @IBOutlet private weak var actionStackView: UIStackView!
  @IBOutlet private weak var backProjectButton: UIButton!
  @IBOutlet private weak var bottomButtonContainerView: UIView!
  @IBOutlet private weak var bottomShareButton: UIButton!
  @IBOutlet private weak var closeBarButtonItem: UIBarButtonItem!
  @IBOutlet private weak var descriptionView: UIView!
  private var descriptionViewController: ProjectDescriptionViewController!
  @IBOutlet private weak var headerView: UIView!
  private var headerViewController: ProjectHeaderViewController!
  @IBOutlet private weak var footerView: UIView!
  private var footerViewController: ProjectFooterViewController!
  @IBOutlet private weak var managePledgeButton: UIButton!
  @IBOutlet private weak var rewardsView: UIView!
  private var rewardsViewController: RewardsViewController!
  @IBOutlet private weak var starButton: UIButton!
  @IBOutlet private weak var topShareButton: UIButton!
  @IBOutlet private weak var viewPledgeButton: UIButton!

  internal func configureWith(project project: Project, refTag: RefTag?) {
    self.viewModel.inputs.configureWith(project: project, refTag: refTag)
    self.shareViewModel.inputs.configureWith(shareContext: .project(project))
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.descriptionViewController = self.childViewControllers
      .flatMap { $0 as? ProjectDescriptionViewController }
      .first

    self.headerViewController = self.childViewControllers
      .flatMap { $0 as? ProjectHeaderViewController }
      .first
    self.headerView.hidden = true
    self.headerViewController.delegate = self

    self.footerViewController = self.childViewControllers
      .flatMap { $0 as? ProjectFooterViewController }
      .first
    self.footerView.hidden = true
    self.footerViewController.delegate = self

    self.rewardsViewController = self.childViewControllers
      .flatMap { $0 as? RewardsViewController }
      .first

    self.topShareButton.addTarget(self, action: #selector(shareButtonTapped),
                                  forControlEvents: .TouchUpInside)
    self.bottomShareButton.addTarget(self, action: #selector(shareButtonTapped),
                                     forControlEvents: .TouchUpInside)
    self.starButton.addTarget(self, action: #selector(starButtonTapped), forControlEvents: .TouchUpInside)
    self.backProjectButton.addTarget(self, action: #selector(backProjectButtonTapped),
                                     forControlEvents: .TouchUpInside)
    self.managePledgeButton.addTarget(self, action: #selector(managePledgeButtonTapped),
                                      forControlEvents: .TouchUpInside)
    self.viewPledgeButton.addTarget(self, action: #selector(viewPledgeButtonTapped),
                                    forControlEvents: .TouchUpInside)

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  override func bindStyles() {
    super.bindStyles()
    self
      |> baseControllerStyle()

    self.actionStackView
      |> UIStackView.lens.spacing .~ 32
      |> UIStackView.lens.distribution .~ .FillEqually

    [self.starButton, self.topShareButton]
      ||> UIButton.lens.title(forState: .Normal) .~ nil
      ||> UIButton.lens.contentCompressionResistancePriorityForAxis(.Horizontal) .~ UILayoutPriorityRequired

    self.starButton
      |> UIButton.lens.image(forState: .Normal)
        .~ UIImage(named: "star-icon", inBundle: .framework, compatibleWithTraitCollection: nil)
      |> UIButton.lens.image(forState: .Highlighted)
        .~ UIImage(named: "star-filled-icon", inBundle: .framework, compatibleWithTraitCollection: nil)
      |> UIButton.lens.image(forState: .Selected)
        .~ UIImage(named: "star-filled-icon", inBundle: .framework, compatibleWithTraitCollection: nil)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.project_accessibility_button_star_label() }

    self.topShareButton
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }
      |> UIButton.lens.image(forState: .Normal)
        .~ UIImage(named: "share-icon", inBundle: .framework, compatibleWithTraitCollection: nil)

    self.closeBarButtonItem
      |> UIBarButtonItem.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
      |> UIBarButtonItem.lens.title .~ nil
      |> UIBarButtonItem.lens.image
        .~ UIImage(named: "close-icon", inBundle: .framework, compatibleWithTraitCollection: nil)

    self.backProjectButton
      |> greenButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.project_back_button() }

    self.managePledgeButton
      |> navyButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.project_manage_button() }

    self.viewPledgeButton
      |> navyButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.project_view_button() }

    self.bottomShareButton
      |> lightNavyButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in
        Strings.dashboard_accessibility_label_share_project()
    }

    self.bottomButtonContainerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(1))
      |> UIView.lens.backgroundColor .~ UIColor.ksr_navy_200.colorWithAlphaComponent(0.4)
  }
  // swiftlint:enable function_body_length

  override func bindViewModel() {
    super.bindViewModel()

    self.backProjectButton.rac.hidden = self.viewModel.outputs.backProjectButtonHidden
    self.descriptionView.rac.hidden = self.viewModel.outputs.descriptionViewHidden
    self.managePledgeButton.rac.hidden = self.viewModel.outputs.managePledgeButtonHidden
    self.rewardsView.rac.hidden = self.viewModel.outputs.rewardsViewHidden
    self.bottomShareButton.rac.hidden = self.viewModel.outputs.bottomShareButtonHidden
    self.starButton.rac.accessibilityHint = self.viewModel.outputs.starButtonAccessibilityHint
    self.starButton.rac.selected = self.viewModel.outputs.starButtonSelected
    self.viewPledgeButton.rac.hidden = self.viewModel.outputs.viewPledgeButtonHidden

    self.viewModel.outputs.configureChildViewControllersWithProject
      .observeNext { [weak self] p in
        self?.descriptionViewController.configureWith(project: p)
        self?.footerViewController.configureWith(project: p)
        self?.headerViewController.configureWith(project: p)
        self?.rewardsViewController.configureWith(project: p)
    }

    self.viewModel.outputs.transferFooterAndHeaderToDescriptionController
      .observeForUI()
      .observeNext { [weak self] in
        self?.transferFooterAndHeaderToDescriptionController()
    }

    self.viewModel.outputs.transferFooterAndHeaderToRewardsController
      .observeForUI()
      .observeNext { [weak self] in
        self?.transferFooterAndHeaderToRewardsController()
    }

    self.viewModel.outputs.notifyDescriptionToExpand
      .observeNext { [weak self] in
        self?.descriptionViewController.expandDescription()
    }

    self.viewModel.outputs.showProjectStarredPrompt
      .observeForUI()
      .observeNext { [weak self] in
        self?.showProjectStarredPrompt(message: $0)
    }

    self.viewModel.outputs.goToLoginTout
      .observeForUI()
      .observeNext { [weak self] in
        self?.goToLoginTout()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForUI()
      .observeNext { [weak self] in self?.showShareSheet($0) }

    self.shareViewModel.outputs.showShareCompose
      .observeForUI()
      .observeNext { [weak self] in self?.showShareCompose($0) }
  }

  private func transferFooterAndHeaderToDescriptionController() {
    let offset = CGPoint.init(
      x: self.rewardsViewController.tableView.contentOffset.x,
      y: self.rewardsViewController.tableView.contentOffset.y +
        self.rewardsViewController.tableView.contentInset.top
    )

    self.rewardsViewController.transfer(headerView: nil, previousContentOffset: nil)
    self.descriptionViewController.transfer(headerView: self.headerViewController.view,
                                            footerView: self.footerViewController.view,
                                            previousContentOffset: offset)
  }

  private func transferFooterAndHeaderToRewardsController() {
    let offset = self.descriptionViewController.webView.scrollView.contentOffset

    self.descriptionViewController.transfer(headerView: nil,
                                            footerView: nil,
                                            previousContentOffset: nil)
    self.rewardsViewController.transfer(headerView: self.headerViewController.view,
                                        previousContentOffset: offset)
  }

  private func showProjectStarredPrompt(message message: String) {
    let alert = UIAlertController.alert(nil, message: message, handler: nil)
    self.presentViewController(alert, animated: true, completion: nil)
  }

  private func goToLoginTout() {
    guard let vc = UIStoryboard(name: "Login", bundle: .framework)
      .instantiateViewControllerWithIdentifier("LoginToutViewController") as? LoginToutViewController else {
      fatalError("Could not instantiate LoginToutViewController.")
    }

    vc.configureWith(loginIntent: .starProject)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] in
      self?.shareViewModel.inputs.shareActivityCompletion(activityType: $0,
                                                          completed: $1,
                                                          returnedItems: $2,
                                                          activityError: $3)
    }

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      controller.modalPresentationStyle = .Popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = self.topShareButton
    }

    self.presentViewController(controller, animated: true, completion: nil)
  }

  private func showShareCompose(controller: SLComposeViewController) {
    controller.completionHandler = { [weak self] in
      self?.shareViewModel.inputs.shareComposeCompletion(result: $0)
    }
    self.presentViewController(controller, animated: true, completion: nil)
  }

  @IBAction private func closeButtonTapped() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @objc private func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc private func starButtonTapped() {
    self.viewModel.inputs.starButtonTapped()
  }

  @objc private func backProjectButtonTapped() {
    self.viewModel.inputs.backProjectButtonTapped()
  }

  @objc private func managePledgeButtonTapped() {
    self.viewModel.inputs.managePledgeButtonTapped()
  }

  @objc private func viewPledgeButtonTapped() {
    self.viewModel.inputs.viewPledgeButtonTapped()
  }
}

extension ProjectMagazineViewController: ProjectHeaderViewControllerDelegate {
  internal func projectHeaderShowCampaignTab() {
    self.viewModel.inputs.showCampaignTab()
  }

  internal func projectHeaderShowRewardsTab() {
    self.viewModel.inputs.showRewardsTab()
  }
}

extension ProjectMagazineViewController: ProjectFooterViewControllerDelegate {
  func projectFooterExpandDescription() {
    self.viewModel.inputs.expandDescription()
  }
}
