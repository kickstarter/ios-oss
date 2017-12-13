import KsApi
import Library
import Prelude
import ReactiveSwift
import ReactiveExtensions
import StoreKit
import UIKit

internal final class ThanksViewController: UIViewController, UITableViewDelegate {

  @IBOutlet fileprivate weak var closeButton: UIButton!
  @IBOutlet fileprivate weak var shareMoreButton: UIButton!
  @IBOutlet fileprivate weak var projectsTableView: UITableView!
  @IBOutlet fileprivate weak var backedLabel: UILabel!
  @IBOutlet fileprivate weak var recommendationsLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var thankYouLabel: UILabel!

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

    self.projectsTableView.register(nib: .DiscoveryPostcardCell)
    self.projectsTableView.register(nib: .ThanksCategoryCell)

    self.projectsTableView.dataSource = self.dataSource
    self.projectsTableView.delegate = self

    self.closeButton.addTarget(self,
                               action: #selector(closeButtonTapped),
                               for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.closeButton
      |> UIButton.lens.title(forState: .normal) .~ nil
      |> UIButton.lens.image(forState: .normal) .~ image(named: "close-icon")
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Closes_project() }

    _ = self.projectsTableView
      |> UITableView.lens.separatorStyle .~ .none
      |> UITableView.lens.rowHeight .~ UITableViewAutomaticDimension
      |> UITableView.lens.estimatedRowHeight .~ 550

    _ = self.thankYouLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ UIFont.ksr_title1(size: 36)
      |> UILabel.lens.text %~ { _ in Strings.Thank_you_exclamation() }
      |> UILabel.lens.isAccessibilityElement .~ false

    _ = self.backedLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900

    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ .ksr_text_dark_grey_900

    _ = self.recommendationsLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.Other_projects_you_might_like() }

    _ = self.shareMoreButton
      |> borderButtonStyle
      |> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_500.cgColor
      |> UIButton.lens.layer.cornerRadius .~ 0
      |> UIButton.lens.targets .~ [(self, #selector(shareMoreButtonTapped), .touchUpInside)]
      |> UIButton.lens.title(forState: .normal) %~ { _ in
          Strings.project_checkout_share_buttons_more_share_options()
        }

    if let navigationController = self.navigationController {
      _ = navigationController
      |> UINavigationController.lens.navigationBarHidden .~ true
    }
  }

    override func bindViewModel() {
    super.bindViewModel()

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
        self?.projectsTableView.reloadData()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self]  controller, _ in self?.showShareSheet(controller) }
  }

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
    if #available(iOS 10.3, *) {
      SKStoreReviewController.requestReview()
    } else {
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

  internal func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.projectTapped(project)
    } else if let category = self.dataSource.categoryAtIndexPath(indexPath) {
      self.viewModel.inputs.categoryCellTapped(category)
    }
  }

  @objc fileprivate func shareMoreButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc fileprivate func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }
}

extension ThanksViewController: ProjectNavigatorDelegate {
  func transitionedToProject(at index: Int) {}
}
