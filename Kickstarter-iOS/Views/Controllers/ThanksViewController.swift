import KsApi
import Library
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Social
import UIKit

internal final class ThanksViewController: UIViewController, UICollectionViewDelegate {

  @IBOutlet private weak var projectNameLabel: StyledLabel!
  @IBOutlet private weak var facebookButton: BorderButton!
  @IBOutlet private weak var twitterButton: BorderButton!
  @IBOutlet private weak var shareMoreButton: BorderButton!
  @IBOutlet private weak var doneButton: UIBarButtonItem!
  @IBOutlet private weak var projectsCollectionView: UICollectionView!

  private let viewModel: ThanksViewModelType = ThanksViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()
  private let dataSource = ThanksProjectsDataSource()

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

  // swiftlint:disable function_body_length
  override func bindViewModel() {
    super.bindViewModel()

    self.facebookButton.rac.hidden = self.viewModel.outputs.facebookButtonIsHidden
    self.twitterButton.rac.hidden = self.viewModel.outputs.twitterButtonIsHidden

    self.viewModel.outputs.backedProjectText
      .observeForUI()
      .observeNext { [weak self] text in
        self?.projectNameLabel.setHTML(text)
    }

    self.viewModel.outputs.dismissViewController
    .observeForUI()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.viewModel.outputs.goToDiscovery
      .observeForUI()
      .observeNext { [weak self] params in
        self?.goToDiscovery(params: params)
    }

    self.viewModel.outputs.goToAppStoreRating
      .observeForUI()
      .observeNext { [weak self] link in
        self?.goToAppStore(link: link)
    }

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] (project, reftag) in
        self?.goToProject(project, reftag: reftag)
    }

    self.viewModel.outputs.showRatingAlert
      .observeForUI()
      .observeNext { [weak self] in
        self?.showRatingAlert()
    }

    self.viewModel.outputs.showGamesNewsletterAlert
      .observeForUI()
      .observeNext { [weak self] in
        self?.showGamesNewsletterAlert()
    }

    self.viewModel.outputs.showGamesNewsletterOptInAlert
      .observeForUI()
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
      .observeForUI()
      .observeNext { [weak self] projects, category in
        self?.dataSource.loadData(projects: projects, category: category)
        self?.projectsCollectionView.reloadData()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForUI()
      .observeNext { [weak self] in self?.showShareSheet($0) }

    self.shareViewModel.outputs.showShareCompose
      .observeForUI()
      .observeNext { [weak self] in self?.showShareCompose($0) }
  }
  // swiftlint:enable function_body_length

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.project(project)
    self.shareViewModel.inputs.configureWith(shareContext: .thanks(project))
  }

  private func goToDiscovery(params params: DiscoveryParams) {
    self.dismissViewControllerAnimated(true, completion: nil)
    // go to discovery
  }

  private func goToAppStore(link link: String) {
    guard let url = NSURL(string: link) else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  private func goToProject(project: Project, reftag: RefTag) {
    guard let projectViewController = UIStoryboard(name: "Project", bundle: nil)
      .instantiateViewControllerWithIdentifier("ProjectViewController") as? ProjectViewController else {
        fatalError("Couldn't instantiate view controller.")
    }

    projectViewController.configureWith(project: project, refTag: reftag)
    self.navigationController?.pushViewController(projectViewController, animated: true)
  }

  private func showRatingAlert() {
    self.presentViewController(
      UIAlertController.rating(
        yesHandler: { [weak self] action in
          self?.viewModel.inputs.rateNowButtonPressed()
        }, remindHandler: { [weak self] action in
          self?.viewModel.inputs.rateRemindLaterButtonPressed()
        }, noHandler: { [weak self] action in
          self?.viewModel.inputs.rateNoThanksButtonPressed()
      }),
      animated: true,
      completion: nil
    )
  }

  private func showGamesNewsletterAlert() {
    self.presentViewController(
      UIAlertController.games(
        subscribeHandler: { [weak self] action in
          self?.viewModel.inputs.gamesNewsletterSignupButtonPressed()
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
      self.viewModel.inputs.projectPressed(project)
    } else if let category = self.dataSource.categoryAtIndexPath(indexPath) {
      self.viewModel.inputs.categoryCellPressed(category)
    }
  }

  @IBAction func facebookButtonPressed(sender: AnyObject) {
    self.shareViewModel.inputs.facebookButtonTapped()
  }

  @IBAction func twitterButtonPressed(sender: AnyObject) {
    self.shareViewModel.inputs.twitterButtonTapped()
  }

  @IBAction func shareMoreButtonPressed(sender: AnyObject) {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @IBAction func doneButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.closeButtonPressed()
  }
}
