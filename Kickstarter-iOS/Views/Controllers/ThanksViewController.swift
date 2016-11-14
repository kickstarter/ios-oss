import KsApi
import Library
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Social
import UIKit

internal final class ThanksViewController: UIViewController, UICollectionViewDelegate {

  @IBOutlet private weak var facebookButton: UIButton!
  @IBOutlet private weak var twitterButton: UIButton!
  @IBOutlet private weak var shareMoreButton: UIButton!
  @IBOutlet private weak var doneButton: UIBarButtonItem!
  @IBOutlet private weak var projectsCollectionView: UICollectionView!
  @IBOutlet private weak var backedLabel: UILabel!
  @IBOutlet private weak var recommendationsLabel: UILabel!
  @IBOutlet private weak var woohooLabel: UILabel!

  private let viewModel: ThanksViewModelType = ThanksViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()
  private let dataSource = ThanksProjectsDataSource()

  internal static func configuredWith(project project: Project) -> ThanksViewController {
    let vc = Storyboard.Thanks.instantiate(ThanksViewController)
    vc.viewModel.inputs.project(project)
    vc.shareViewModel.inputs.configureWith(shareContext: .thanks(project))
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.projectsCollectionView.dataSource = self.dataSource
    self.projectsCollectionView.delegate = self

    self.viewModel.inputs.facebookIsAvailable(
      SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
    )
    self.viewModel.inputs.twitterIsAvailable(
      SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    )
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.setHidesBackButton(true, animated: animated)
  }

  override func bindStyles() {
    super.bindStyles()

    self |> baseControllerStyle()

    self.woohooLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.font .~ UIFont.ksr_title2().bolded
      |> UILabel.lens.text %~ { _ in Strings.project_checkout_share_exclamation() }
      |> UILabel.lens.isAccessibilityElement .~ false

    self.backedLabel |> UILabel.lens.textColor .~ .ksr_text_navy_900

    self.recommendationsLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_900
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.project_checkout_looking_for_more_projects_check_these_out() }

    self.facebookButton
      |> facebookThanksButtonStyle
      |> UIButton.lens.targets .~ [(self, #selector(facebookButtonTapped), .TouchUpInside)]
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Share_this_project_on_Facebook() }

    self.twitterButton
      |> twitterButtonStyle
      |> UIButton.lens.targets .~ [(self, #selector(twitterButtonTapped), .TouchUpInside)]
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Share_this_project_on_Twitter() }

    self.shareMoreButton
      |> borderButtonStyle
      |> UIButton.lens.targets .~ [(self, #selector(shareMoreButtonTapped), .TouchUpInside)]
      |> UIButton.lens.title(forState: .Normal) %~ { _ in
        Strings.project_checkout_share_buttons_more_share_options()
    }

    self.doneButton
      |> doneBarButtonItemStyle
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(doneButtonTapped))
  }

  // swiftlint:disable function_body_length
  override func bindViewModel() {
    super.bindViewModel()

    self.facebookButton.rac.hidden = self.viewModel.outputs.facebookButtonIsHidden
    self.twitterButton.rac.hidden = self.viewModel.outputs.twitterButtonIsHidden
    self.backedLabel.rac.attributedText = self.viewModel.outputs.backedProjectText

    self.viewModel.outputs.dismissToRootViewController
    .observeForControllerAction()
      .observeNext { [weak self] in
        self?.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.viewModel.outputs.goToDiscovery
      .observeForControllerAction()
      .observeNext { [weak self] params in
        self?.goToDiscovery(params: params)
    }

    self.viewModel.outputs.goToAppStoreRating
      .observeForControllerAction()
      .observeNext { [weak self] link in
        self?.goToAppStore(link: link)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeNext { [weak self] project, projects, refTag in
        self?.goToProject(project, projects: projects, refTag: refTag)
    }

    self.viewModel.outputs.showRatingAlert
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.showRatingAlert()
    }

    self.viewModel.outputs.showGamesNewsletterAlert
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.showGamesNewsletterAlert()
    }

    self.viewModel.outputs.showGamesNewsletterOptInAlert
      .observeForControllerAction()
      .observeNext { [weak self] title in
        self?.showGamesNewsletterOptInAlert(title: title)
    }

    self.viewModel.outputs.updateUserInEnvironment
      .observeNext { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.viewModel.inputs.userUpdated()
    }

    self.viewModel.outputs.postUserUpdatedNotification
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.outputs.showRecommendations
      .observeForControllerAction()
      .observeNext { [weak self] projects, category in
        self?.dataSource.loadData(projects: projects, category: category)
        self?.projectsCollectionView.reloadData()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showShareSheet($0) }

    self.shareViewModel.outputs.showShareCompose
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showShareCompose($0) }
  }
  // swiftlint:enable function_body_length

  private func goToDiscovery(params params: DiscoveryParams) {
    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { $0.switchToDiscovery(params: params) }

    self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

  private func goToAppStore(link link: String) {
    guard let url = NSURL(string: link) else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  private func goToProject(project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: projects,
                                                           navigatorDelegate: self)
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func showRatingAlert() {
    self.presentViewController(
      UIAlertController.rating(
        yesHandler: { [weak self] action in
          self?.viewModel.inputs.rateNowButtonTapped()
        }, remindHandler: { [weak self] action in
          self?.viewModel.inputs.rateRemindLaterButtonTapped()
        }, noHandler: { [weak self] action in
          self?.viewModel.inputs.rateNoThanksButtonTapped()
      }),
      animated: true,
      completion: nil
    )
  }

  private func showGamesNewsletterAlert() {
    self.presentViewController(
      UIAlertController.games(
        subscribeHandler: { [weak self] action in
          self?.viewModel.inputs.gamesNewsletterSignupButtonTapped()
      }),
      animated: true,
      completion: nil
    )
  }

  private func showGamesNewsletterOptInAlert(title title: String) {
    self.presentViewController(
      UIAlertController.newsletterOptIn(title),
      animated: true,
      completion: nil
    )
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
      popover?.sourceView = self.shareMoreButton
    }

    self.presentViewController(controller, animated: true, completion: nil)
  }

  private func showShareCompose(controller: SLComposeViewController) {
    controller.completionHandler = { [weak self] in
      self?.shareViewModel.inputs.shareComposeCompletion(result: $0)
    }
    self.presentViewController(controller, animated: true, completion: nil)
  }

  internal func collectionView(collectionView: UICollectionView,
                               didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.projectTapped(project)
    } else if let category = self.dataSource.categoryAtIndexPath(indexPath) {
      self.viewModel.inputs.categoryCellTapped(category)
    }
  }

  @objc private func facebookButtonTapped() {
    self.shareViewModel.inputs.facebookButtonTapped()
  }

  @objc private func twitterButtonTapped() {
    self.shareViewModel.inputs.twitterButtonTapped()
  }

  @objc private func shareMoreButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc private func doneButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }
}

extension ThanksViewController: ProjectNavigatorDelegate {
}
