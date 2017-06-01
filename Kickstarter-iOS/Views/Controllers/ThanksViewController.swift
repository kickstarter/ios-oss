import KsApi
import Library
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Social
import UIKit

internal final class ThanksViewController: UIViewController, UICollectionViewDelegate {

  @IBOutlet fileprivate weak var facebookButton: UIButton!
  @IBOutlet fileprivate weak var twitterButton: UIButton!
  @IBOutlet fileprivate weak var shareMoreButton: UIButton!
  @IBOutlet fileprivate weak var doneButton: UIBarButtonItem!
  @IBOutlet fileprivate weak var projectsCollectionView: UICollectionView!
  @IBOutlet fileprivate weak var backedLabel: UILabel!
  @IBOutlet fileprivate weak var recommendationsLabel: UILabel!
  @IBOutlet fileprivate weak var woohooLabel: UILabel!

  fileprivate let viewModel: ThanksViewModelType = ThanksViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()
  fileprivate let dataSource = ThanksProjectsDataSource()

  internal static func configuredWith(project: Project) -> ThanksViewController {
    let vc = Storyboard.Thanks.instantiate(ThanksViewController.self)
    vc.viewModel.inputs.project(project)
    vc.shareViewModel.inputs.configureWith(shareContext: .thanks(project), shareContextView: nil)
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.projectsCollectionView.dataSource = self.dataSource
    self.projectsCollectionView.delegate = self

    self.viewModel.inputs.facebookIsAvailable(
      SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)
    )
    self.viewModel.inputs.twitterIsAvailable(
      SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
    )
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.setHidesBackButton(true, animated: animated)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self |> baseControllerStyle()

    _ = self.woohooLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ UIFont.ksr_title2().bolded
      |> UILabel.lens.text %~ { _ in Strings.project_checkout_share_exclamation() }
      |> UILabel.lens.isAccessibilityElement .~ false

    _ = self.backedLabel |> UILabel.lens.textColor .~ .ksr_text_navy_900

    _ = self.recommendationsLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_900
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.project_checkout_looking_for_more_projects_check_these_out() }

    _ = self.facebookButton
      |> facebookThanksButtonStyle
      |> UIButton.lens.targets .~ [(self, #selector(facebookButtonTapped), .touchUpInside)]
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Share_this_project_on_Facebook() }

    _ = self.twitterButton
      |> twitterButtonStyle
      |> UIButton.lens.targets .~ [(self, #selector(twitterButtonTapped), .touchUpInside)]
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Share_this_project_on_Twitter() }

    _ = self.shareMoreButton
      |> borderButtonStyle
      |> UIButton.lens.targets .~ [(self, #selector(shareMoreButtonTapped), .touchUpInside)]
      |> UIButton.lens.title(forState: .normal) %~ { _ in
        Strings.project_checkout_share_buttons_more_share_options()
    }

    _ = self.doneButton
      |> doneBarButtonItemStyle
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(doneButtonTapped))
  }

    override func bindViewModel() {
    super.bindViewModel()

    self.facebookButton.rac.hidden = self.viewModel.outputs.facebookButtonIsHidden
    self.twitterButton.rac.hidden = self.viewModel.outputs.twitterButtonIsHidden
    self.backedLabel.rac.attributedText = self.viewModel.outputs.backedProjectText

    self.viewModel.outputs.dismissToRootViewController
    .observeForControllerAction()
      .observeValues { [weak self] in
        self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    self.viewModel.outputs.goToDiscovery
      .observeForControllerAction()
      .observeValues { [weak self] params in
        self?.goToDiscovery(params: params)
    }

    self.viewModel.outputs.goToAppStoreRating
      .observeForControllerAction()
      .observeValues { [weak self] link in
        self?.goToAppStore(link: link)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, projects, refTag in
        self?.goToProject(project, projects: projects, refTag: refTag)
    }

    self.viewModel.outputs.showRatingAlert
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showRatingAlert()
    }

    self.viewModel.outputs.showGamesNewsletterAlert
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showGamesNewsletterAlert()
    }

    self.viewModel.outputs.showGamesNewsletterOptInAlert
      .observeForControllerAction()
      .observeValues { [weak self] title in
        self?.showGamesNewsletterOptInAlert(title: title)
    }

    self.viewModel.outputs.updateUserInEnvironment
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.viewModel.inputs.userUpdated()
    }

    self.viewModel.outputs.postUserUpdatedNotification
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.showRecommendations
      .observeForControllerAction()
      .observeValues { [weak self] projects, category in
        self?.dataSource.loadData(projects: projects, category: category)
        self?.projectsCollectionView.reloadData()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self]  controller, _ in self?.showShareSheet(controller) }

    self.shareViewModel.outputs.showShareCompose
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showShareCompose($0) }
  }
  // swiftlint:enable function_body_length

  fileprivate func goToDiscovery(params: DiscoveryParams) {
    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { $0.switchToDiscovery(params: params) }

    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
  }

  fileprivate func goToAppStore(link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.openURL(url)
  }

  fileprivate func goToProject(_ project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: projects,
                                                           navigatorDelegate: self)
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func showRatingAlert() {
    self.present(
      UIAlertController.rating(
        yesHandler: { [weak self] _ in
          self?.viewModel.inputs.rateNowButtonTapped()
        }, remindHandler: { [weak self] _ in
          self?.viewModel.inputs.rateRemindLaterButtonTapped()
        }, noHandler: { [weak self] _ in
          self?.viewModel.inputs.rateNoThanksButtonTapped()
      }),
      animated: true,
      completion: nil
    )
  }

  fileprivate func showGamesNewsletterAlert() {
    self.present(
      UIAlertController.games(
        subscribeHandler: { [weak self] _ in
          self?.viewModel.inputs.gamesNewsletterSignupButtonTapped()
      }),
      animated: true,
      completion: nil
    )
  }

  fileprivate func showGamesNewsletterOptInAlert(title: String) {
    self.present(
      UIAlertController.newsletterOptIn(title),
      animated: true,
      completion: nil
    )
  }

  fileprivate func showShareSheet(_ controller: UIActivityViewController) {

    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in

      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(activityType: activityType,
                    completed: completed,
                    returnedItems: returnedItems,
                    activityError: error)
      )
    }

    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = self.shareMoreButton
    }

    self.present(controller, animated: true, completion: nil)
  }

  fileprivate func showShareCompose(_ controller: SLComposeViewController) {
    controller.completionHandler = { [weak self] in
      self?.shareViewModel.inputs.shareComposeCompletion(result: $0)
    }
    self.present(controller, animated: true, completion: nil)
  }

  internal func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.projectTapped(project)
    } else if let category = self.dataSource.categoryAtIndexPath(indexPath) {
      self.viewModel.inputs.categoryCellTapped(category)
    }
  }

  @objc fileprivate func facebookButtonTapped() {
    self.shareViewModel.inputs.facebookButtonTapped()
  }

  @objc fileprivate func twitterButtonTapped() {
    self.shareViewModel.inputs.twitterButtonTapped()
  }

  @objc fileprivate func shareMoreButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc fileprivate func doneButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }
}

extension ThanksViewController: ProjectNavigatorDelegate {
  func transitionedToProject(at index: Int) {}
}
