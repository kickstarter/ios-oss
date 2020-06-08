import KsApi
import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import StoreKit
import UIKit

internal final class ThanksViewController: UIViewController, UITableViewDelegate {
  @IBOutlet fileprivate var closeButton: UIButton!
  @IBOutlet fileprivate var shareMoreButton: UIButton!
  @IBOutlet fileprivate var projectsTableView: UITableView!
  @IBOutlet fileprivate var backedLabel: UILabel!
  @IBOutlet fileprivate var recommendationsLabel: UILabel!
  @IBOutlet fileprivate var separatorView: UIView!
  @IBOutlet fileprivate var thankYouLabel: UILabel!
  @IBOutlet fileprivate var headerView: UIView!

  fileprivate let viewModel: ThanksViewModelType = ThanksViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()
  fileprivate let dataSource = ThanksProjectsDataSource()

  internal static func configured(with data: ThanksPageData) -> ThanksViewController {
    let vc = Storyboard.Thanks.instantiate(ThanksViewController.self)
    vc.viewModel.inputs.configure(with: data)
    vc.shareViewModel.inputs.configureWith(shareContext: .thanks(data.project), shareContextView: nil)
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.projectsTableView.register(nib: .DiscoveryPostcardCell)
    self.projectsTableView.register(nib: .ThanksCategoryCell)
    self.projectsTableView.registerCellClass(DiscoveryProjectCardCell.self)

    self.projectsTableView.dataSource = self.dataSource
    self.projectsTableView.delegate = self

    self.closeButton.addTarget(
      self,
      action: #selector(self.closeButtonTapped),
      for: .touchUpInside
    )

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if let headerView = projectsTableView.tableHeaderView {
      let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
      self.updateHeaderView(height: height)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.closeButton
      |> UIButton.lens.title(for: .normal) .~ nil
      |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross")
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Closes_project() }

    _ = self.projectsTableView
      |> UITableView.lens.separatorStyle .~ .none
      |> UITableView.lens.rowHeight .~ UITableView.automaticDimension
      |> UITableView.lens.estimatedRowHeight .~ 550

    _ = self.thankYouLabel
      |> UILabel.lens.textColor .~ .ksr_soft_black
      |> UILabel.lens.font .~ UIFont.ksr_title1(size: 36)
      |> UILabel.lens.text %~ { _ in Strings.Thank_you_exclamation() }
      |> UILabel.lens.isAccessibilityElement .~ false

    _ = self.backedLabel
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ .ksr_soft_black

    _ = self.recommendationsLabel
      |> UILabel.lens.textColor .~ .ksr_soft_black
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.Other_projects_you_might_like() }

    _ = self.shareMoreButton
      |> greyButtonStyle
      |> UIButton.lens.targets .~ [(self, #selector(self.shareMoreButtonTapped), .touchUpInside)]
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.project_accessibility_button_share_label()
      }

    if let navigationController = self.navigationController {
      _ = navigationController
        |> UINavigationController.lens.isNavigationBarHidden .~ true
    }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.backedLabel.rac.attributedText = self.viewModel.outputs.backedProjectText

    self.viewModel.outputs.dismissToRootViewControllerAndPostNotification
      .observeForControllerAction()
      .observeValues { [weak self] in
        NotificationCenter.default.post($0)
        self?.dismiss(animated: true)
      }

    self.viewModel.outputs.goToDiscovery
      .observeForControllerAction()
      .observeValues { [weak self] params in
        self?.goToDiscovery(params: params)
      }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, projects, refTag in
        self?.goToProject(project, projects: projects, refTag: refTag)
      }

    self.viewModel.outputs.postContextualNotification
      .observeForUI()
      .observeValues {
        NotificationCenter.default.post(
          Notification(
            name: .ksr_showNotificationsDialog,
            userInfo: [
              UserInfoKeys.context: PushNotificationDialog.Context.pledge,
              UserInfoKeys.viewController: self
            ]
          )
        )
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
      .observeForUI()
      .observeValues { [weak self] projects, category, nativeProjectCardsVariant in
        self?.dataSource.loadData(
          projects: projects,
          category: category,
          nativeProjectCardsVariant: nativeProjectCardsVariant
        )
        self?.projectsTableView.reloadData()
      }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller) }
  }

  private func updateHeaderView(height: CGFloat) {
    var headerFrame = self.headerView.frame
    guard height != headerFrame.size.height else { return }

    headerFrame.size.height = height
    self.headerView.frame = headerFrame
    self.projectsTableView.tableHeaderView = self.headerView
  }

  fileprivate func goToDiscovery(params: DiscoveryParams) {
    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { $0.switchToDiscovery(params: params) }

    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
  }

  fileprivate func goToAppStore(link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.open(url)
  }

  fileprivate func goToProject(_ project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(
      project: project,
      refTag: refTag,
      initialPlaylist: projects,
      navigatorDelegate: self
    )
    if UIDevice.current.userInterfaceIdiom == .pad {
      vc.modalPresentationStyle = .fullScreen
    }
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func showRatingAlert() {
    SKStoreReviewController.requestReview()
  }

  fileprivate func showGamesNewsletterAlert() {
    self.present(
      UIAlertController.games(
        subscribeHandler: { [weak self] _ in
          self?.viewModel.inputs.gamesNewsletterSignupButtonTapped()
        }
      ),
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
        with: .init(
          activityType: activityType,
          completed: completed,
          returnedItems: returnedItems,
          activityError: error
        )
      )
    }

    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = self.shareMoreButton
    }

    self.present(controller, animated: true, completion: nil)
  }

  internal func tableView(
    _: UITableView, willDisplay cell: UITableViewCell,
    forRowAt _: IndexPath
  ) {
    if let cell = cell as? ThanksCategoryCell {
      cell.delegate = self
    }
  }

  internal func tableView(
    _: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.projectTapped(project)
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
  func transitionedToProject(at _: Int) {}
}

extension ThanksViewController: ThanksCategoryCellDelegate {
  func thanksCategoryCell(_: ThanksCategoryCell, didTapSeeAllProjectsWith category: KsApi.Category) {
    self.viewModel.inputs.categoryCellTapped(category)
  }
}
