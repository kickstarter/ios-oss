import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude
import KsApi
import Models
import Social

internal final class ThanksViewController: UIViewController, UICollectionViewDelegate {

  @IBOutlet private weak var projectNameLabel: StyledLabel!
  @IBOutlet private weak var facebookButton: BorderButton!
  @IBOutlet private weak var twitterButton: BorderButton!
  @IBOutlet private weak var shareMoreButton: BorderButton!
  @IBOutlet private weak var doneButton: UIBarButtonItem!
  @IBOutlet private weak var projectsCollectionView: UICollectionView!

  private let viewModel: ThanksViewModelType = ThanksViewModel()
  private let dataSource = ThanksProjectsDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.projectsCollectionView.dataSource = self.dataSource
    self.projectsCollectionView.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.facebookIsAvailable
      .observeForUI()
      .observeNext { [weak self] available in self?.facebookButton.hidden = !available }

    self.viewModel.outputs.twitterIsAvailable
      .observeForUI()
      .observeNext { [weak self] available in self?.twitterButton.hidden = !available }

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

    self.viewModel.outputs.showShareSheet
      .observeForUI()
      .observeNext { [weak self] project in
        self?.showShareSheet(project: project)
    }

    self.viewModel.outputs.showFacebookShare
      .observeForUI()
      .observeNext { [weak self] project in
        self?.showFacebookShare(project: project)
    }

    self.viewModel.outputs.showTwitterShare
      .observeForUI()
      .observeNext { [weak self] project in
        self?.showTwitterShare(project: project)
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
  }
  // swiftlint:enable function_body_length

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.project(project)
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

  private func showShareSheet(project project: Project) {
    let activityVC = UIActivityViewController.shareProject(
      project: project,
      completionHandler: { activityType, shouldShowPasteboardAlert, completed in
        if let validType = activityType {
          self.viewModel.inputs.shareFinishedWithShareType(validType, completed: completed)
        } else {
          self.viewModel.inputs.cancelShareSheetButtonPressed()
        }

        if shouldShowPasteboardAlert {
          let alert = UIAlertController.projectCopiedToPasteboard(projectURL: project.urls.web.project)
          self.presentViewController(alert, animated: true, completion: nil)
        }
    })

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      activityVC.modalPresentationStyle = .Popover
      self.presentViewController(activityVC, animated: true, completion: nil)
      if let popover = activityVC.popoverPresentationController {
        popover.permittedArrowDirections = .Up
        popover.sourceView = self.shareMoreButton
        popover.sourceRect = CGRect(origin: CGPoint(x: 0, y: 0),
                                    size: self.shareMoreButton.frame.size)
      }
    } else {
      self.presentViewController(activityVC, animated: true, completion: nil)
    }
  }

  private func showFacebookShare(project project: Project) {
    if let fbVC = SLComposeViewController.facebookShareProject(
      project: project,
      completionHandler: { result in
        if result == .Done {
          self.viewModel.inputs.shareFinishedWithShareType(UIActivityTypePostToFacebook, completed: true)
        } else if result == .Cancelled {
          self.viewModel.inputs.shareFinishedWithShareType(UIActivityTypePostToFacebook, completed: false)
        }
      }) {
      self.presentViewController(fbVC, animated: true, completion: nil)
    }
  }

  private func showTwitterShare(project project: Project) {
    if let twitterVC = SLComposeViewController.twitterShareCheckout(
      project: project,
      completionHandler: { result in
        if result == .Done {
          self.viewModel.inputs.shareFinishedWithShareType(UIActivityTypePostToFacebook, completed: true)
        } else if result == .Cancelled {
          self.viewModel.inputs.shareFinishedWithShareType(UIActivityTypePostToFacebook, completed: false)
        }
      }) {
      self.presentViewController(twitterVC, animated: true, completion: nil)
    }
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

  internal func collectionView(collectionView: UICollectionView,
                               didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.projectPressed(project)
    } else if let category = self.dataSource.categoryAtIndexPath(indexPath) {
      self.viewModel.inputs.categoryCellPressed(category)
    }
  }

  @IBAction func facebookButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.facebookButtonPressed()
  }

  @IBAction func twitterButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.twitterButtonPressed()
  }

  @IBAction func shareMoreButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.shareMoreButtonPressed()
  }

  @IBAction func doneButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.closeButtonPressed()
  }
}
